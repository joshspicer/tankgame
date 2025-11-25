//
//  CrashReporterTests.swift
//  tankgame Shared
//
//  Created by Copilot on 11/23/25.
//

import Foundation

#if DEBUG
/// Test utilities for the crash reporter - only available in debug builds
class CrashReporterTests {
    
    /// Test that crash reporter can export reports
    static func testExportCrashReports() {
        print("=== Testing Crash Reporter Export ===")
        
        let reports = CrashReporter.shared.getAllCrashReports()
        print("Found \(reports.count) crash report(s)")
        
        if let exported = CrashReporter.shared.exportCrashReports() {
            print("Successfully exported crash reports:")
            print(exported)
        } else {
            print("No crash reports to export")
        }
    }
    
    /// Create a sample crash report for testing
    static func createSampleCrashReport() {
        print("=== Creating Sample Crash Report ===")
        
        // Create a sample exception
        let exception = NSException(
            name: .init("TestCrashException"),
            reason: "This is a test crash for development purposes",
            userInfo: [
                "test": true,
                "purpose": "Testing crash reporting system"
            ]
        )
        
        // This will create a crash report without actually crashing
        // We're just simulating what would happen
        let report: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "exception_name": exception.name.rawValue,
            "exception_reason": exception.reason ?? "Unknown",
            "call_stack": Thread.callStackSymbols,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            "app_build": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown",
            "os_version": ProcessInfo.processInfo.operatingSystemVersionString,
            "device_model": "Simulator"
        ]
        
        // Save it manually
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let crashDir = appSupport.appendingPathComponent("CrashReports")
        try? FileManager.default.createDirectory(at: crashDir, withIntermediateDirectories: true)
        
        let filename = "crash_test_\(Date().timeIntervalSince1970).json"
        let fileURL = crashDir.appendingPathComponent(filename)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: report, options: .prettyPrinted)
            try jsonData.write(to: fileURL)
            print("✓ Sample crash report created at: \(fileURL.path)")
            print("\nYou can submit this report using:")
            print("python3 scripts/submit_crash_report.py '\(fileURL.path)'")
        } catch {
            print("✗ Failed to create sample crash report: \(error)")
        }
    }
    
    /// Clear all crash reports
    static func clearAllReports() {
        print("=== Clearing All Crash Reports ===")
        CrashReporter.shared.clearAllCrashReports()
        print("✓ All crash reports cleared")
    }
    
    /// Print information about the crash reporter
    static func printInfo() {
        print("=== Crash Reporter Info ===")
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let crashDir = appSupport.appendingPathComponent("CrashReports")
        print("Crash reports directory: \(crashDir.path)")
        
        let reports = CrashReporter.shared.getAllCrashReports()
        print("Number of crash reports: \(reports.count)")
        
        for (index, report) in reports.enumerated() {
            print("\nReport \(index + 1):")
            print("  Exception: \(report["exception_name"] ?? "Unknown")")
            print("  Reason: \(report["exception_reason"] ?? "Unknown")")
            print("  Timestamp: \(report["timestamp"] ?? "Unknown")")
        }
    }
    
    /// Validate that a crash report has all required fields for issue tracking
    /// - Parameter report: The crash report dictionary to validate
    /// - Returns: A tuple of (isValid, missingFields)
    static func validateCrashReport(_ report: [String: Any]) -> (isValid: Bool, missingFields: [String]) {
        let requiredFields = [
            "timestamp",
            "exception_name",
            "exception_reason",
            "call_stack",
            "app_version",
            "app_build",
            "os_version",
            "device_model"
        ]
        
        var missingFields: [String] = []
        for field in requiredFields {
            if let value = report[field] {
                // Check for empty strings
                if let stringValue = value as? String, stringValue.isEmpty {
                    missingFields.append(field)
                }
                // Check for empty arrays
                else if let arrayValue = value as? [Any], arrayValue.isEmpty {
                    missingFields.append(field)
                }
            } else {
                missingFields.append(field)
            }
        }
        
        return (missingFields.isEmpty, missingFields)
    }
    
    /// Run validation tests on all crash reports
    /// - Parameter createIfEmpty: Whether to create a sample report if none exist (default: true)
    /// - Returns: True if all reports pass validation
    static func runValidationTests(createIfEmpty: Bool = true) -> Bool {
        print("=== Running Crash Report Validation Tests ===")
        
        var reports = CrashReporter.shared.getAllCrashReports()
        
        if reports.isEmpty && createIfEmpty {
            print("No crash reports to validate. Creating a test report...")
            createSampleCrashReport()
            // Refresh reports list after creating sample
            reports = CrashReporter.shared.getAllCrashReports()
            if reports.isEmpty {
                print("✗ Failed to create sample crash report")
                return false
            }
        } else if reports.isEmpty {
            print("No crash reports to validate.")
            return true
        }
        
        var allPassed = true
        for (index, report) in reports.enumerated() {
            let (isValid, missingFields) = validateCrashReport(report)
            if isValid {
                print("✓ Report \(index + 1): Valid")
            } else {
                print("✗ Report \(index + 1): Invalid - missing fields: \(missingFields.joined(separator: ", "))")
                allPassed = false
            }
        }
        
        print("\n=== Validation Summary ===")
        print("Total reports: \(reports.count)")
        print("Result: \(allPassed ? "All tests passed ✓" : "Some tests failed ✗")")
        
        return allPassed
    }
}
#endif
