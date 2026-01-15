//
//  CrashReporterXCTests.swift
//  tankgame Shared
//
//  Created by Copilot on 1/15/26.
//

import XCTest
import Foundation

#if DEBUG
/// XCTest unit tests for the CrashReporter - quick tests that can be run via Xcode Test Navigator
class CrashReporterXCTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Clear any existing crash reports before each test
        CrashReporter.shared.clearAllCrashReports()
    }
    
    override func tearDown() {
        // Clean up after each test
        CrashReporter.shared.clearAllCrashReports()
        super.tearDown()
    }
    
    // MARK: - Quick Tests
    
    /// Quick test: Verify crash reporter singleton exists
    func testCrashReporterExists() {
        XCTAssertNotNil(CrashReporter.shared, "CrashReporter singleton should exist")
    }
    
    /// Quick test: Verify getAllCrashReports returns empty array initially
    func testGetAllCrashReportsEmpty() {
        let reports = CrashReporter.shared.getAllCrashReports()
        XCTAssertTrue(reports.isEmpty, "Should have no crash reports initially")
    }
    
    /// Quick test: Verify exportCrashReports returns nil when no reports
    func testExportCrashReportsNil() {
        let exported = CrashReporter.shared.exportCrashReports()
        XCTAssertNil(exported, "Should return nil when no crash reports exist")
    }
    
    /// Quick test: Verify clearAllCrashReports works
    func testClearAllCrashReports() {
        // This test just verifies the method doesn't crash
        CrashReporter.shared.clearAllCrashReports()
        let reports = CrashReporter.shared.getAllCrashReports()
        XCTAssertTrue(reports.isEmpty, "Should have no crash reports after clearing")
    }
    
    /// Quick test: Verify install method doesn't crash
    func testInstallDoesNotCrash() {
        // This test verifies the install method can be called
        CrashReporter.shared.install()
        // If we get here without crashing, the test passes
        XCTAssertTrue(true)
    }
}
#endif
