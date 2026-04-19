# flutter_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Patrol tests

Use an explicit device to avoid Patrol's interactive device prompt:

```bash
flutter devices
patrol test --target patrol_test/smoke_test.dart --device <device-id>
```

## CI test run

Use the repo script so integration tests always run with an explicit device:

```bash
./scripts/run_flutter_ci_tests.sh
```

You can override the integration device and target:

```bash
INTEGRATION_DEVICE=macos INTEGRATION_TARGET=integration_test/app_flow_test.dart ./scripts/run_flutter_ci_tests.sh
```
