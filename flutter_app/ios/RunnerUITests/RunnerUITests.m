@import XCTest;
@import patrol;

// Use Patrol's runner so its SwiftPM module names and discovery protocol stay
// aligned with the installed plugin, rather than copying its implementation.
PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)
