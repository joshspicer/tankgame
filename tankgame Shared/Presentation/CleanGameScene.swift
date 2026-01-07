//
//  CleanGameScene.swift
//  tankgame Shared
//
//  Clean Architecture - Presentation Layer
//

import SpriteKit

/// Clean game scene using new architecture
final class CleanGameScene: SKScene {
    
    // Coordinator
    private let coordinator: GameCoordinator
    private let renderer: GameRenderer
    
    // Input tracking
    private var touchStartPosition: CGPoint?
    private var isFiring: Bool = false
    
    init(size: CGSize, coordinator: GameCoordinator, renderer: GameRenderer) {
        self.coordinator = coordinator
        self.renderer = renderer
        super.init(size: size)
        self.scaleMode = .aspectFit
        self.backgroundColor = .black
        
        setupCoordinatorCallbacks()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCoordinatorCallbacks() {
        coordinator.onSessionUpdated = { [weak self] session in
            self?.renderGame(session)
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Initial render if session exists
        if let session = coordinator.session {
            renderGame(session)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        coordinator.update(currentTime: currentTime)
    }
    
    private func renderGame(_ session: GameSessionEntity) {
        renderer.render(session: session, in: self)
    }
    
    #if os(iOS) || os(tvOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Right side of screen: fire button
        if location.x > size.width * 0.7 {
            isFiring = true
            coordinator.fireWeapon(currentTime: Date().timeIntervalSince1970)
        } else {
            // Left side: movement joystick
            touchStartPosition = location
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let startPos = touchStartPosition else { return }
        
        let currentPos = touch.location(in: self)
        let delta = CGPoint(x: currentPos.x - startPos.x, y: currentPos.y - startPos.y)
        
        // Determine direction based on largest delta
        let direction: Direction
        if abs(delta.x) > abs(delta.y) {
            direction = delta.x > 0 ? .right : .left
        } else {
            direction = delta.y > 0 ? .up : .down
        }
        
        // Only move if delta is significant
        if sqrt(delta.x * delta.x + delta.y * delta.y) > 20 {
            _ = coordinator.movePlayer(direction: direction)
            touchStartPosition = currentPos // Update for continuous movement
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStartPosition = nil
        isFiring = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    #endif
}
