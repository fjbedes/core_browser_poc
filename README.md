### How to Start Using VS Code

1. **Clone the project** to your local machine.
2. Open the project in **VS Code**.
3. Run the following command to fetch dependencies:

   ```sh
   flutter pub get
   ```

4. If you see outdated dependencies, run:

   ```sh
   flutter pub outdated
   flutter pub upgrade
   ```

5. Select a device to run the application:

   - Navigate to **View > Command Palette**.
   - Search for **Flutter: Select Device** and choose a target device.

6. Run the application using:

   ```sh
   flutter run lib/main.dart
   ```

### Features (Tested on Android only | Requires Android 12, API Level 31)

- A lightweight Flutter-based web browser
