# Assignment Firebase (Flutter)

Minimal Flutter project scaffold created by the assistant.

Getting started:

1. Make sure Flutter SDK is installed and on your PATH.
2. From the project root run:

```powershell
flutter pub get
flutter run
```

If platform folders (android/ios/windows/macos/linux) are missing, generate them with:

```powershell
flutter create .
```

This project includes a minimal `lib/main.dart`. Add Firebase packages and configuration when ready.

Firebase setup notes:

- An `android/app/google-services.json` is present in this workspace. Android should work with the existing `lib/firebase_options.dart` which currently contains Android options.
- If you need iOS, web, macOS, Windows, or Linux configuration, run the FlutterFire CLI to generate `lib/firebase_options.dart` for those platforms:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

- Make sure to add the `GoogleService-Info.plist` for iOS in `ios/Runner` if you configure iOS, and update `web/index.html` for web if needed.

Security & next steps:

- Review Firestore security rules to restrict access to `users`, `courses`, and `enrollments`.
- Consider preventing duplicate enrollments by enforcing unique documents or checks in `CourseService.enrollInCourse`.

