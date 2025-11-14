//
//  GameConstants.swift
//  tankgame Shared
//
//  Centralized constants for game configuration
//

import CoreGraphics

/// Centralized constants for game configuration and visual parameters
enum GameConstants {
    // MARK: - Grid Configuration
    
    /// Size of each tile in points
    static let tileSize: CGFloat = 64
    
    /// Number of rows/columns in the game grid
    static let gridSize = 8
    
    // MARK: - Tank Configuration
    
    /// Size of tank body relative to tile size
    static let tankBodyScale: CGFloat = 0.7
    
    /// Size of tank barrel relative to tile size
    static let tankBarrelWidth: CGFloat = 0.2
    static let tankBarrelHeight: CGFloat = 0.5
    static let tankBarrelOffset: CGFloat = 0.35
    
    // MARK: - Projectile Configuration
    
    /// Size of projectile relative to tile size
    static let projectileScale: CGFloat = 0.5
    
    /// Update interval for projectiles in seconds
    static let projectileUpdateInterval: TimeInterval = 0.05
    
    // MARK: - Animation Timings
    
    /// Duration of rainbow color animation cycle
    static let rainbowAnimationDuration: TimeInterval = 3.0
    
    /// Number of color steps in rainbow animation
    static let rainbowColorSteps = 12
    
    /// Duration of explosion animation
    static let explosionDuration: TimeInterval = 0.6
    
    /// Duration of flash effect in explosion
    static let explosionFlashDuration: TimeInterval = 0.4
    
    /// Number of particles in explosion effect
    static let explosionParticleCount = 12
    
    /// Particle velocity in explosion
    static let explosionParticleVelocity: CGFloat = 150
    
    /// Size of explosion flash relative to tile size
    static let explosionFlashScale: CGFloat = 0.5
    static let explosionFlashMaxScale: CGFloat = 2.5
    
    // MARK: - Movement Configuration
    
    /// Movement interval for continuous joystick input (seconds)
    static let movementInterval: TimeInterval = 0.12
    
    // MARK: - Joystick Configuration
    
    /// Radius of joystick base
    static let joystickBaseRadius: CGFloat = 50
    
    /// Radius of joystick handle
    static let joystickHandleRadius: CGFloat = 25
    
    /// Maximum distance joystick handle can move from center
    static let joystickMaxDistance: CGFloat = 30
    
    /// Hit area radius for joystick (larger than visual size)
    static let joystickHitRadius: CGFloat = 150
    
    /// Minimum distance from center to register direction
    static let joystickDeadZone: CGFloat = 20
    
    // MARK: - Button Configuration
    
    /// Radius of fire button
    static let fireButtonRadius: CGFloat = 40
    
    /// Hit area radius for fire button
    static let fireButtonHitRadius: CGFloat = 50
    
    // MARK: - UI Layout
    
    /// Position of joystick from left edge
    static let joystickPositionX: CGFloat = 80
    
    /// Position of joystick from bottom edge
    static let joystickPositionY: CGFloat = 100
    
    /// Position of fire button from right edge
    static let fireButtonOffsetX: CGFloat = 80
    
    /// Position of fire button from bottom edge
    static let fireButtonPositionY: CGFloat = 100
    
    /// Grid vertical offset from center
    static let gridVerticalOffset: CGFloat = 50
    
    // MARK: - Round Timing
    
    /// Delay before showing round end message (wait for explosion)
    static let roundEndDelay: TimeInterval = 1.0
    
    /// Delay before starting next round
    static let nextRoundDelay: TimeInterval = 2.0
    
    /// Additional delay for next round start
    static let nextRoundStartDelay: TimeInterval = 0.5
    
    /// Delay after connection before starting game
    static let gameStartDelay: TimeInterval = 1.0
    
    // MARK: - Multiplayer Configuration
    
    /// Timeout for peer invitations in seconds
    static let peerInvitationTimeout: TimeInterval = 30
    
    /// Delay for permission check response
    static let permissionCheckDelay: TimeInterval = 0.5
    
    // MARK: - Grid Generation
    
    /// Minimum wall density for grid generation
    static let minWallDensity: Double = 0.15
    
    /// Maximum wall density for grid generation
    static let maxWallDensity: Double = 0.30
}
