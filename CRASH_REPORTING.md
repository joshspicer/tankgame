# Crash Reporting System

This repository includes a **fully automated** crash reporting system that captures crashes and automatically creates GitHub issues assigned to @copilot.

## How It Works

1. **Crash Detection**: The app uses a lightweight crash reporter (`CrashReporter.swift`) that captures uncaught exceptions and crash data.

2. **Local Storage**: Crash reports are saved locally on the device in JSON format in the Application Support directory.

3. **Automatic Upload**: Crash reports are automatically uploaded to `https://tankgame.spicer.dev/crash` when they occur or on next app launch.

4. **Direct Issue Creation**: The Flask server receives crash reports and **directly creates GitHub issues** using the GitHub API.

5. **Automatic Assignment**: Issues are created with:
   - Crash details (exception name, reason, stack trace)
   - App version and OS version
   - Automatic assignment to @copilot
   - Bug and crash-report labels

## Components

### CrashReporter.swift

Located in `tankgame Shared/CrashReporter.swift`, this class:
- Installs exception handlers on app launch
- Captures crash data including:
  - Exception name and reason
  - Stack trace (call stack symbols)
  - App version and build number
  - OS version
  - Device model
  - Timestamp
- Saves crashes to JSON files locally
- **Automatically uploads crash reports to the server**
- Server URL is configurable via `CrashReportingServerURL` in Info.plist
- Uploads pending crash reports on next app launch
- Manages old crash reports (keeps the 10 most recent)

### Crash Reporter Server

Located in `server/`, this Flask application:
- Receives crash reports via HTTP POST at `/crash` endpoint
- Validates and processes crash data
- **Directly creates GitHub issues using the GitHub API**
- Assigns issues to @copilot
- Adds appropriate labels (bug, crash-report)
- Runs as a containerized service with Docker Compose
- Deployed at `https://tankgame.spicer.dev`

## Usage

### Automatic Integration

The crash reporter is automatically initialized in `AppDelegate.swift` when the app launches:

```swift
CrashReporter.shared.install()
```

**That's it!** Crash reports are now automatically:
- Captured when they occur
- Saved locally for reliability
- Uploaded to the server
- Converted into GitHub issues

### Configuration

The crash reporting server URL is configured in the Info.plist files:

**TankGame-iOS-Info.plist**, **TankGame-macOS-Info.plist**, **TankGame-tvOS-Info.plist**:
```xml
<key>CrashReportingServerURL</key>
<string>https://tankgame.spicer.dev/crash</string>
```

To change the server URL (e.g., for development/staging), update this value in the appropriate Info.plist file. The app will read this configuration at runtime.

### Accessing Crash Reports

The CrashReporter class provides methods to access stored crash reports:

```swift
// Get all crash reports
let reports = CrashReporter.shared.getAllCrashReports()

// Export all crash reports as JSON string
if let jsonString = CrashReporter.shared.exportCrashReports() {
    print(jsonString)
}

// Clear all crash reports
CrashReporter.shared.clearAllCrashReports()
```

### Testing the Crash Reporter

#### Creating a Test Crash Report

To test the crash reporting system in development, you can create a sample crash report:

1. In `AppDelegate.swift`, uncomment the test utility line:
```swift
#if DEBUG
CrashReporterTests.createSampleCrashReport()
#endif
```

2. Run the app - it will create a sample crash report

3. Check the console output for the crash report file path

4. The crash report will be automatically uploaded to the server and converted to a GitHub issue

**Note**: Test crash reports are uploaded just like real ones, so use with caution!

#### Other Test Utilities

```swift
#if DEBUG
// Print crash reporter info and list all crash reports
CrashReporterTests.printInfo()

// Export all crash reports to console
CrashReporterTests.testExportCrashReports()

// Clear all crash reports
CrashReporterTests.clearAllReports()

// Validate all crash reports have required fields
let allValid = CrashReporterTests.runValidationTests()

// Validate a specific crash report
let (isValid, missingFields) = CrashReporterTests.validateCrashReport(report)
#endif
```

**Note**: Only test this in a development environment, not in production!

## Server Deployment

The crash reporting server is deployed at `https://tankgame.spicer.dev`. See `server/README.md` for deployment instructions.

### Running the Server Locally

For development or self-hosting:

```bash
cd server

# Using Docker Compose (recommended)
echo "GITHUB_TOKEN=your_token" > .env
docker-compose up -d

# Or run directly with Python
pip install -r requirements.txt
export GITHUB_TOKEN="your_token"
python app.py
```

## Crash Report Format

Crash reports are saved in JSON format with the following structure:

```json
{
  "timestamp": "2025-11-23T18:00:00Z",
  "exception_name": "NSGenericException",
  "exception_reason": "Test crash for crash reporting",
  "call_stack": [
    "0   CoreFoundation   0x00007fff2040...",
    "1   libobjc.A.dylib  0x00007fff202..."
  ],
  "app_version": "1.0",
  "app_build": "1",
  "os_version": "Version 18.0 (Build 22A380)",
  "device_model": "iPhone14,2"
}
```

## GitHub Token Requirements

For the server deployment, a GitHub Personal Access Token is required with:
- `repo` scope (for private repos) or `public_repo` (for public repos)
- `workflow` scope (to trigger workflow dispatches)

The token should be set as an environment variable on the server.

## Security Considerations

- **Automatic Transmission**: Crash reports are automatically uploaded to the server when they occur
- **HTTPS**: The server endpoint (`https://tankgame.spicer.dev`) uses HTTPS for encrypted transmission
- **Local Backup**: Crash reports are stored locally first, ensuring no data loss if upload fails
- **Privacy**: Only crash-related data is collected (no user identifiers, location, or personal information)
- **Token Security**: GitHub token is stored securely on the server (not in the app)
- **Rate Limiting**: Consider implementing rate limiting on the server to prevent abuse
- **Retry Logic**: Failed uploads are retried on next app launch

## Architecture

```
[App] → Crash Occurs
  ↓
[CrashReporter.swift] → Captures & Saves Locally
  ↓
[Automatic Upload] → HTTPS POST to https://tankgame.spicer.dev/crash
  ↓
[Flask Server] → Validates & Processes
  ↓
[GitHub API] → Directly Creates Issue & Assigns to @copilot
```

## Future Enhancements

Possible improvements:
- ~~Automatic crash report submission~~ ✅ **Implemented**
- Crash report deduplication on the server
- Symbolication of stack traces for better readability
- Crash analytics dashboard
- User consent dialog before uploading (for privacy compliance)
