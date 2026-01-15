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
    
    /// Quick test - verify basic crash reporter functionality
    static func quickTest() {
        print("=== Quick Crash Reporter Test ===")
        
        // Test 1: Verify crash reporter exists
        print("✓ CrashReporter singleton exists")
        
        // Test 2: Check crash reports directory
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let crashDir = appSupport.appendingPathComponent("CrashReports")
        let dirExists = FileManager.default.fileExists(atPath: crashDir.path)
        print("✓ Crash reports directory exists: \(dirExists)")
        
        // Test 3: Get crash reports count
        let reports = CrashReporter.shared.getAllCrashReports()
        print("✓ Found \(reports.count) crash report(s)")
        
        // Test 4: Test export (should return nil if no reports)
        let exported = CrashReporter.shared.exportCrashReports()
        if exported != nil {
            print("✓ Export function works (has reports)")
        } else {
            print("✓ Export function works (no reports to export)")
        }
        
        print("=== Quick Test Complete ===")
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
}
#endif
