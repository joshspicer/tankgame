# Crash Reporting System

This repository includes an automated crash reporting system that captures crashes and automatically creates GitHub issues assigned to @copilot.

## How It Works

1. **Crash Detection**: The app uses a lightweight crash reporter (`CrashReporter.swift`) that captures uncaught exceptions and crash data.

2. **Local Storage**: Crash reports are saved locally on the device in JSON format in the Application Support directory.

3. **Automatic Issue Creation**: Crash reports can be submitted to GitHub Actions, which automatically creates an issue with:
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
- Manages old crash reports (keeps the 10 most recent)

### GitHub Actions Workflow

The workflow file `.github/workflows/crash-report.yml` handles:
- Receiving crash report data
- Parsing the JSON crash data
- Creating a formatted GitHub issue
- Automatically assigning to @copilot
- Adding appropriate labels

## Usage

### Automatic Integration

The crash reporter is automatically initialized in `AppDelegate.swift` when the app launches:

```swift
CrashReporter.shared.install()
```

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

4. Submit the report using the Python script:
```bash
export GITHUB_TOKEN="your_github_token_here"
python3 scripts/submit_crash_report.py '/path/to/crash_report.json'
```

#### Other Test Utilities

```swift
#if DEBUG
// Print crash reporter info and list all crash reports
CrashReporterTests.printInfo()

// Export all crash reports to console
CrashReporterTests.testExportCrashReports()

// Clear all crash reports
CrashReporterTests.clearAllReports()
#endif
```

**Note**: Only test this in a development environment, not in production!

### Submitting Crash Reports

#### Option 1: Using the Python Script

```bash
# Set your GitHub token
export GITHUB_TOKEN="your_github_token_here"

# Submit a crash report
python3 scripts/submit_crash_report.py path/to/crash_report.json

# Optionally include user email
python3 scripts/submit_crash_report.py path/to/crash_report.json user@example.com
```

#### Option 2: Manual Workflow Dispatch

1. Go to the Actions tab in GitHub
2. Select "Process Crash Reports" workflow
3. Click "Run workflow"
4. Paste the crash report JSON data
5. Optionally add a user email
6. Click "Run workflow"

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

To use the submission script, you need a GitHub Personal Access Token with the following permissions:
- `repo` scope (for private repos) or `public_repo` (for public repos)
- `workflow` scope (to trigger workflow dispatches)

## Security Considerations

- Crash reports are stored locally on the device and never transmitted automatically
- Manual submission requires explicit action
- No personal data is collected beyond what's in the crash stack trace
- The GitHub token must be kept secure and should not be committed to the repository

## Future Enhancements

Possible improvements:
- Automatic crash report submission (with user consent)
- Crash report deduplication
- Symbolication of stack traces
- Crash analytics dashboard
- Integration with external crash reporting services
