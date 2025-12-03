//
//  RoomCodeGenerator.swift
//  tankgame Shared
//
//  Generates and validates room codes for WiFi multiplayer
//

import Foundation

/// Generates and validates room codes for WiFi multiplayer sessions
struct RoomCodeGenerator {
    
    /// Characters used for room codes (excluding confusing chars like 0/O, 1/I/L)
    private static let characters = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"
    
    /// Length of generated room codes
    static let codeLength = 6
    
    /// Generates a random room code
    /// - Returns: A random 6-character alphanumeric room code
    static func generateCode() -> String {
        var code = ""
        for _ in 0..<codeLength {
            let randomIndex = Int.random(in: 0..<characters.count)
            let index = characters.index(characters.startIndex, offsetBy: randomIndex)
            code.append(characters[index])
        }
        return code
    }
    
    /// Validates a room code format
    /// - Parameter code: The room code to validate
    /// - Returns: True if the code is valid format
    static func isValid(_ code: String) -> Bool {
        guard code.count == codeLength else { return false }
        let uppercased = code.uppercased()
        return uppercased.allSatisfy { characters.contains($0) }
    }
    
    /// Normalizes a room code (uppercase, trimmed)
    /// - Parameter code: The room code to normalize
    /// - Returns: Normalized room code
    static func normalize(_ code: String) -> String {
        return code.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
