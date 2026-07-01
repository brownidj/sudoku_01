@import XCTest;
@import ObjectiveC.runtime;
#import <objc/message.h>

@protocol PatrolServerProtocol <NSObject>
@property(nonatomic, assign) BOOL appReady;
- (BOOL)startAndReturnError:(NSError * _Nullable * _Nullable)error;
@end

@protocol ObjCRunDartTestResponseProtocol <NSObject>
@property(nonatomic, readonly) BOOL passed;
@property(nonatomic, copy, readonly, nullable) NSString *details;
@end

@protocol ObjCPatrolAppServiceClientProtocol <NSObject>
- (void)listDartTestsWithCompletion:(void (^_Nonnull)(NSArray<NSDictionary *> *_Nullable,
                                                       NSError *_Nullable))completion;
- (void)runDartTestWithName:(NSString *_Nonnull)name
                 completion:(void (^_Nonnull)(id<ObjCRunDartTestResponseProtocol> _Nullable,
                                              NSError *_Nullable))completion;
@end

static Class PatrolClass(NSString *name) {
  Class klass = NSClassFromString([@"patrol." stringByAppendingString:name]);
  if (klass == Nil) {
    klass = NSClassFromString(name);
  }
  return klass;
}

static NSString *PatrolLocalizedString(NSString *key) {
  Class localizationClass = PatrolClass(@"ObjCLocalization");
  if (localizationClass == Nil) {
    return key;
  }

  SEL selector = NSSelectorFromString(@"getLocalizedStringWithKey:");
  return ((NSString *(*)(id, SEL, NSString *))objc_msgSend)(localizationClass, selector, key);
}

#undef CLEAR_PERMISSIONS
#define CLEAR_PERMISSIONS 0
#undef FULL_ISOLATION
#define FULL_ISOLATION 1

@interface RunnerUITests : XCTestCase
@property(class, strong, nonatomic) NSDictionary *selectedTest;
@end

@implementation RunnerUITests

static NSDictionary *_selectedTest = nil;

+(NSDictionary *)selectedTest {
  return _selectedTest;
}

+(void)setSelectedTest:(NSDictionary *)newSelectedTest {
  if (newSelectedTest != _selectedTest) {
    _selectedTest = [newSelectedTest copy];
  }
}

+(BOOL)instancesRespondToSelector:(SEL)aSelector {
  NSString *name = NSStringFromSelector(aSelector);
  BOOL skip = NO;
  NSDictionary *testInfo = @{@"name" : name, @"skip" : @(skip)};
  [self setSelectedTest:testInfo];

  [self defaultTestSuite]; /* calls testInvocations */
  [super instancesRespondToSelector:aSelector];
  return YES;
}

+(void)uninstallApp {
  XCUIApplication *app = [[XCUIApplication alloc] init];
  NSString *appName = app.label;
  NSLog(@"Uninstalling app: %@", appName);

  [app terminate];

  XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];

  [[XCUIDevice sharedDevice] pressButton:XCUIDeviceButtonHome];
  [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];

  BOOL appFound = NO;
  int maxScreens = 10;
  int currentScreen = 0;

  while (!appFound && currentScreen < maxScreens) {
    NSLog(@"Checking screen %d for app: %@", currentScreen + 1, appName);

    XCUIElement *icon = springboard.icons[appName];

    if (icon.exists && icon.isHittable) {
      NSLog(@"App icon found on screen %d: %@", currentScreen + 1, appName);
      appFound = YES;

      NSLog(@"Long pressing on app icon: %@", appName);
      [icon pressForDuration:1.3];
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];

      NSString *removeAppText = PatrolLocalizedString(@"remove_app");
      XCUIElement *removeAppButton = springboard.buttons[removeAppText];
      if (!removeAppButton.exists) {
        NSLog(@"'%@' button not found", removeAppText);
        return;
      }

      [removeAppButton tap];

      NSString *deleteAppText = PatrolLocalizedString(@"delete_app");
      XCUIElement *deleteAppButton = springboard.alerts.buttons[deleteAppText];
      if (deleteAppButton.exists) {
        [deleteAppButton tap];
        while (deleteAppButton.exists) {
          [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
      }

      NSString *deleteText = PatrolLocalizedString(@"delete");
      XCUIElement *deleteButton = springboard.alerts.buttons[deleteText];
      if (deleteButton.exists) {
        [deleteButton tap];
        while (deleteButton.exists) {
          [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
      }

      NSLog(@"App uninstallation completed");
      return;
    }

    currentScreen++;

    if (currentScreen < maxScreens) {
      NSLog(@"App not found on screen %d, swiping right to next screen", currentScreen);
      XCUICoordinate *startCoordinate = [springboard coordinateWithNormalizedOffset:CGVectorMake(0.8, 0.5)];
      XCUICoordinate *endCoordinate = [springboard coordinateWithNormalizedOffset:CGVectorMake(0.2, 0.5)];
      [startCoordinate pressForDuration:0.0
                   thenDragToCoordinate:endCoordinate
                           withVelocity:XCUIGestureVelocityFast
                    thenHoldForDuration:0.0];
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }
  }

  if (!appFound) {
    NSLog(@"App icon not found on any home screen: %@", appName);
  }
}

+(void)resetPermissions {
  NSLog(@"Clearing permissions");
  XCUIApplication *app = [[XCUIApplication alloc] init];
  if (@available(iOS 13.4, *)) {
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceLocation];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceContacts];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceCalendar];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceReminders];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourcePhotos];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceBluetooth];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceMicrophone];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceCamera];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceHomeKit];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceMediaLibrary];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceKeyboardNetwork];
  }
  if (@available(iOS 14.0, *)) {
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceHealth];
  }
  if (@available(iOS 15.0, *)) {
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceUserTracking];
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceFocus];
  }
  if (@available(iOS 15.4, *)) {
    [app resetAuthorizationStatusForResource:XCUIProtectedResourceLocalNetwork];
  }
}

+(NSArray<NSInvocation *> *)testInvocations {
  id<PatrolServerProtocol> server = (id<PatrolServerProtocol>)[[PatrolClass(@"PatrolServer") alloc] init];

  NSError *err = nil;
  [server startAndReturnError:&err];
  if (err != nil) {
    NSLog(@"patrolServer.start(): failed, err: %@", err);
  }

  __block id<ObjCPatrolAppServiceClientProtocol> appServiceClient =
      (id<ObjCPatrolAppServiceClientProtocol>)[[PatrolClass(@"ObjCPatrolAppServiceClient") alloc] init];

  XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
  XCUIElementQuery *systemAlerts = springboard.alerts;
  if (systemAlerts.buttons[@"Allow"].exists) {
    [systemAlerts.buttons[@"Allow"] tap];
  }

  __block NSArray<NSDictionary *> *dartTests = NULL;
  if ([self selectedTest] != nil) {
    NSLog(@"selectedTest: %@", [self selectedTest]);
    dartTests = [NSArray arrayWithObject:[self selectedTest]];
  } else {
    [[[XCUIApplication alloc] init] launch];
    while (!server.appReady) {
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }
    [appServiceClient
        listDartTestsWithCompletion:^(NSArray<NSDictionary *> *_Nullable tests, NSError *_Nullable listErr) {
          if (listErr != NULL) {
            NSLog(@"listDartTests(): failed, err: %@", listErr);
          }

          dartTests = tests;
        }];

    while (!dartTests) {
      [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }

    NSLog(@"Got %lu Dart tests: %@", dartTests.count, dartTests);
  }

  NSMutableArray<NSInvocation *> *invocations = [[NSMutableArray alloc] init];

  for (NSUInteger i = 0; i < dartTests.count; i++) {
    NSDictionary *dartTest = dartTests[i];
    NSString *dartTestName = dartTest[@"name"];
    BOOL skip = [dartTest[@"skip"] boolValue];

    IMP implementation = imp_implementationWithBlock(^(id _self) {
      NSLog(@"RunnerUITests running Dart test: %@", dartTestName);

      if (CLEAR_PERMISSIONS && i > 0) {
        [self resetPermissions];
        NSLog(@"App permissions cleared");
      }

      if (FULL_ISOLATION && i > 0) {
        NSLog(@"Uninstalling app");
        [self uninstallApp];
        NSLog(@"App uninstallation completed, launching fresh app instance");
      }

      [[[XCUIApplication alloc] init] launch];
      if (skip) {
        XCTSkip(@"Skip that test \"%@\"", dartTestName);
      }

      __block id<ObjCRunDartTestResponseProtocol> response = nil;
      __block NSError *error = nil;
      [appServiceClient
          runDartTestWithName:dartTestName
          completion:^(id<ObjCRunDartTestResponseProtocol> _Nullable r, NSError *_Nullable runErr) {
                     NSString *status;
                     if (runErr != NULL) {
                       error = runErr;
                       status = @"CRASHED";
                     } else {
                       response = r;
                       status = response.passed ? @"PASSED" : @"FAILED";
                     }
                     NSLog(@"runDartTest(\"%@\"): call finished, test result: %@", dartTestName, status);
                   }];

      while (!response && !error) {
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
      }
      BOOL passed = response ? response.passed : NO;
      NSString *details = response ? response.details : @"(no details - app likely crashed)";
      XCTAssertTrue(passed, @"%@", details);
    });
    SEL selector = NSSelectorFromString(dartTestName);
    class_addMethod(self, selector, implementation, "v@:");

    NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;

    NSLog(@"RunnerUITests.testInvocations(): selectorName = %@, signature: %@", dartTestName, signature);

    [invocations addObject:invocation];
  }

  return invocations;
}

@end
