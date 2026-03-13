@import XCTest;
@import patrol;
@import ObjectiveC.runtime;

#undef CLEAR_PERMISSIONS
#define CLEAR_PERMISSIONS 0
#undef FULL_ISOLATION
#define FULL_ISOLATION 1

PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)
