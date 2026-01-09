//
//  SeededRandomNumberGenerator.swift
//  tankgame Shared
//
//  Seeded random number generator for consistent, reproducible random sequences
//

import Foundation

/// A seeded random number generator that produces consistent sequences for a given seed
/// Uses a Linear Congruential Generator (LCG) algorithm
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt32

    init(seed: UInt32) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        // Linear congruential generator with common constants
        state = state &* 1664525 &+ 1013904223
        return UInt64(state)
    }

    /// Generate a random double value between 0.0 and 1.0
    mutating func nextDouble() -> Double {
        let value = next()
        return Double(value) / Double(UInt32.max)
    }
}
