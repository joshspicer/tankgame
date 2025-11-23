//
//  CrashReporter.swift
//  tankgame Shared
//
//  Created by Copilot on 11/23/25.
//

import Foundation

/// A lightweight crash reporting system that captures uncaught exceptions and crash data
class CrashReporter {
    static let shared = CrashReporter()
    
    private let crashReportsDirectory: URL
    private let maxReportsToKeep = 10
    
    private init() {
        // Create crashes directory in app support
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        crashReportsDirectory = appSupport.appendingPathComponent("CrashReports")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: crashReportsDirectory, withIntermediateDirectories: true)
    }
    
    /// Install crash handlers
    func install() {
        // Set up uncaught exception handler
        NSSetUncaughtExceptionHandler { exception in
            CrashReporter.shared.handleException(exception)
        }
        
        // Check for and process any pending crash reports from previous session
        processPendingCrashReports()
    }
    
    /// Handle an uncaught exception
    private func handleException(_ exception: NSException) {
        let crashReport = generateCrashReport(exception: exception)
        saveCrashReport(crashReport)
    }
    
    /// Generate a crash report from an exception
    private func generateCrashReport(exception: NSException) -> [String: Any] {
        var report: [String: Any] = [:]
        
        report["timestamp"] = ISO8601DateFormatter().string(from: Date())
        report["exception_name"] = exception.name.rawValue
        report["exception_reason"] = exception.reason ?? "Unknown"
        report["call_stack"] = exception.callStackSymbols
        report["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        report["app_build"] = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        report["os_version"] = ProcessInfo.processInfo.operatingSystemVersionString
        report["device_model"] = getDeviceModel()
        
        return report
    }
    
    /// Save a crash report to disk
    private func saveCrashReport(_ report: [String: Any]) {
        let timestamp = Date().timeIntervalSince1970
        let filename = "crash_\(timestamp).json"
        let fileURL = crashReportsDirectory.appendingPathComponent(filename)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: report, options: .prettyPrinted)
            try jsonData.write(to: fileURL)
            print("Crash report saved: \(fileURL.path)")
        } catch {
            print("Failed to save crash report: \(error)")
        }
        
        // Clean up old reports
        cleanupOldReports()
    }
    
    /// Process any pending crash reports from previous session
    private func processPendingCrashReports() {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: crashReportsDirectory, includingPropertiesForKeys: nil)
            let crashFiles = files.filter { $0.pathExtension == "json" }
            
            if !crashFiles.isEmpty {
                print("Found \(crashFiles.count) pending crash report(s)")
                // In a real implementation, this would upload to a server
                // For now, we just log their existence
            }
        } catch {
            print("Failed to check for pending crash reports: \(error)")
        }
    }
    
    /// Clean up old crash reports, keeping only the most recent ones
    private func cleanupOldReports() {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: crashReportsDirectory, includingPropertiesForKeys: [.creationDateKey])
            let crashFiles = files.filter { $0.pathExtension == "json" }
            
            if crashFiles.count > maxReportsToKeep {
                // Sort by creation date
                let sortedFiles = try crashFiles.sorted { file1, file2 in
                    let date1 = try file1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    let date2 = try file2.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    return date1 < date2
                }
                
                // Delete oldest files
                let filesToDelete = sortedFiles.prefix(crashFiles.count - maxReportsToKeep)
                for file in filesToDelete {
                    try FileManager.default.removeItem(at: file)
                }
            }
        } catch {
            print("Failed to cleanup old crash reports: \(error)")
        }
    }
    
    /// Get the device model identifier
    private func getDeviceModel() -> String {
        #if os(iOS)
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
        #elseif os(macOS)
        return "Mac"
        #elseif os(tvOS)
        return "AppleTV"
        #else
        return "Unknown"
        #endif
    }
    
    /// Get all crash reports
    func getAllCrashReports() -> [[String: Any]] {
        var reports: [[String: Any]] = []
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: crashReportsDirectory, includingPropertiesForKeys: nil)
            let crashFiles = files.filter { $0.pathExtension == "json" }
            
            for file in crashFiles {
                let data = try Data(contentsOf: file)
                if let report = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    reports.append(report)
                }
            }
        } catch {
            print("Failed to read crash reports: \(error)")
        }
        
        return reports
    }
    
    /// Export all crash reports as a single JSON string
    func exportCrashReports() -> String? {
        let reports = getAllCrashReports()
        guard !reports.isEmpty else { return nil }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: reports, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Failed to export crash reports: \(error)")
            return nil
        }
    }
    
    /// Delete all crash reports
    func clearAllCrashReports() {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: crashReportsDirectory, includingPropertiesForKeys: nil)
            for file in files {
                try FileManager.default.removeItem(at: file)
            }
            print("All crash reports cleared")
        } catch {
            print("Failed to clear crash reports: \(error)")
        }
    }
}
