//
//  SpriteRenderers.swift
//  tankgame Shared
//
//  Consolidated sprite rendering for tanks, dolphins, and lizards
//

import SpriteKit

// MARK: - Rainbow Animation Helper

class RainbowAnimationHelper {
    private let animationDuration: TimeInterval = 3.0
    private let numberOfColors = 12

    func addRainbowAnimation(to sprite: SKSpriteNode, phaseOffset: CGFloat = 0) {
        var colorActions: [SKAction] = []

        for i in 0...numberOfColors {
            let hue = (CGFloat(i) / CGFloat(numberOfColors) + phaseOffset).truncatingRemainder(dividingBy: 1.0)
            let color = SKColor(hue: hue, saturation: 0.9, brightness: 0.9, alpha: 1.0)
            let colorAction = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: animationDuration / Double(numberOfColors))
            colorActions.append(colorAction)
        }

        let rainbowSequence = SKAction.sequence(colorActions)
        let repeatForever = SKAction.repeatForever(rainbowSequence)

        sprite.run(repeatForever)
    }

    func addRainbowAnimationToShape(_ shape: SKShapeNode, phaseOffset: CGFloat = 0) {
        var colorActions: [SKAction] = []

        for i in 0...numberOfColors {
            let hue = (CGFloat(i) / CGFloat(numberOfColors) + phaseOffset).truncatingRemainder(dividingBy: 1.0)
            let color = SKColor(hue: hue, saturation: 0.9, brightness: 0.9, alpha: 0.9)
            let colorAction = SKAction.run { [weak shape, color] in
                shape?.fillColor = color
                shape?.strokeColor = color.withAlphaComponent(0.5)
            }
            let waitAction = SKAction.wait(forDuration: animationDuration / Double(numberOfColors))
            colorActions.append(SKAction.sequence([colorAction, waitAction]))
        }

        let rainbowSequence = SKAction.sequence(colorActions)
        let repeatForever = SKAction.repeatForever(rainbowSequence)

        shape.run(repeatForever)
    }
}

// MARK: - Tank Sprite Renderer

class TankSpriteRenderer {
    let tileSize: CGFloat
    private let animationHelper: RainbowAnimationHelper

    init(tileSize: CGFloat) {
        self.tileSize = tileSize
        self.animationHelper = RainbowAnimationHelper()
    }

    func createTankNode(color: SKColor, direction: Direction) -> SKNode {
        let tankNode = SKNode()

        // Tank treads
        let leftTread = SKSpriteNode(color: color.withAlphaComponent(0.6), size: CGSize(width: tileSize * 0.15, height: tileSize * 0.75))
        leftTread.position = CGPoint(x: -tileSize * 0.3, y: 0)
        tankNode.addChild(leftTread)

        let rightTread = SKSpriteNode(color: color.withAlphaComponent(0.6), size: CGSize(width: tileSize * 0.15, height: tileSize * 0.75))
        rightTread.position = CGPoint(x: tileSize * 0.3, y: 0)
        tankNode.addChild(rightTread)

        // Tank body
        let body = SKSpriteNode(color: color, size: CGSize(width: tileSize * 0.55, height: tileSize * 0.65))
        tankNode.addChild(body)

        // Turret base
        let turretBase = SKShapeNode(circleOfRadius: tileSize * 0.25)
        turretBase.fillColor = color.withAlphaComponent(0.9)
        turretBase.strokeColor = color.withAlphaComponent(0.5)
        turretBase.lineWidth = 2
        turretBase.position = CGPoint(x: 0, y: 0)
        tankNode.addChild(turretBase)

        // Tank barrel
        let barrel = SKSpriteNode(color: color.withAlphaComponent(0.8), size: CGSize(width: tileSize * 0.15, height: tileSize * 0.5))
        barrel.position = CGPoint(x: 0, y: tileSize * 0.35)
        tankNode.addChild(barrel)

        // Barrel muzzle
        let muzzle = SKSpriteNode(color: .darkGray, size: CGSize(width: tileSize * 0.18, height: tileSize * 0.12))
        muzzle.position = CGPoint(x: 0, y: tileSize * 0.56)
        tankNode.addChild(muzzle)

        // Add rainbow animations
        animationHelper.addRainbowAnimation(to: leftTread, phaseOffset: 0)
        animationHelper.addRainbowAnimation(to: rightTread, phaseOffset: 0)
        animationHelper.addRainbowAnimation(to: body, phaseOffset: 0.1)
        animationHelper.addRainbowAnimation(to: barrel, phaseOffset: 0.2)
        animationHelper.addRainbowAnimationToShape(turretBase, phaseOffset: 0.15)

        tankNode.zRotation = CGFloat(direction.angle)

        return tankNode
    }
}

// MARK: - Dolphin Sprite Renderer

class DolphinSpriteRenderer {
    let tileSize: CGFloat

    init(tileSize: CGFloat) {
        self.tileSize = tileSize
    }

    func createDolphinNode(color: SKColor, direction: Direction) -> SKNode {
        let dolphinNode = SKNode()

        // Dolphin body
        let body = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.5, height: tileSize * 0.75))
        body.fillColor = color
        body.strokeColor = color.withAlphaComponent(0.7)
        body.lineWidth = 2
        dolphinNode.addChild(body)

        // Dolphin snout
        let snout = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.2, height: tileSize * 0.25))
        snout.fillColor = color.withAlphaComponent(0.9)
        snout.strokeColor = .clear
        snout.position = CGPoint(x: 0, y: tileSize * 0.4)
        dolphinNode.addChild(snout)

        // Dorsal fin
        let dorsalFin = createTriangleFin(size: CGSize(width: tileSize * 0.15, height: tileSize * 0.25), color: color.withAlphaComponent(0.85))
        dorsalFin.position = CGPoint(x: tileSize * 0.1, y: 0)
        dorsalFin.zRotation = -.pi / 4
        dolphinNode.addChild(dorsalFin)

        // Flippers
        let leftFlipper = createFlipper(color: color.withAlphaComponent(0.75))
        leftFlipper.position = CGPoint(x: -tileSize * 0.25, y: -tileSize * 0.05)
        leftFlipper.zRotation = .pi / 6
        dolphinNode.addChild(leftFlipper)

        let rightFlipper = createFlipper(color: color.withAlphaComponent(0.75))
        rightFlipper.position = CGPoint(x: tileSize * 0.25, y: -tileSize * 0.05)
        rightFlipper.zRotation = -.pi / 6
        dolphinNode.addChild(rightFlipper)

        // Tail flukes
        let tailFlukes = createTailFlukes(color: color.withAlphaComponent(0.8))
        tailFlukes.position = CGPoint(x: 0, y: -tileSize * 0.4)
        dolphinNode.addChild(tailFlukes)

        // Eye
        let eye = SKShapeNode(circleOfRadius: tileSize * 0.05)
        eye.fillColor = .white
        eye.strokeColor = .black
        eye.lineWidth = 1
        eye.position = CGPoint(x: -tileSize * 0.1, y: tileSize * 0.2)
        dolphinNode.addChild(eye)

        let pupil = SKShapeNode(circleOfRadius: tileSize * 0.025)
        pupil.fillColor = .black
        pupil.strokeColor = .clear
        pupil.position = CGPoint(x: -tileSize * 0.1, y: tileSize * 0.2)
        dolphinNode.addChild(pupil)

        // Add ocean animation
        addOceanAnimation(to: body, baseColor: color)

        dolphinNode.zRotation = CGFloat(direction.angle)

        return dolphinNode
    }

    private func createTriangleFin(size: CGSize, color: SKColor) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size.height / 2))
        path.addLine(to: CGPoint(x: -size.width / 2, y: -size.height / 2))
        path.addLine(to: CGPoint(x: size.width / 2, y: -size.height / 2))
        path.closeSubpath()

        let fin = SKShapeNode(path: path)
        fin.fillColor = color
        fin.strokeColor = .clear
        return fin
    }

    private func createFlipper(color: SKColor) -> SKShapeNode {
        let flipper = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.15, height: tileSize * 0.08))
        flipper.fillColor = color
        flipper.strokeColor = .clear
        return flipper
    }

    private func createTailFlukes(color: SKColor) -> SKNode {
        let tailNode = SKNode()

        let leftFluke = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.2, height: tileSize * 0.1))
        leftFluke.fillColor = color
        leftFluke.strokeColor = .clear
        leftFluke.position = CGPoint(x: -tileSize * 0.1, y: 0)
        leftFluke.zRotation = .pi / 4
        tailNode.addChild(leftFluke)

        let rightFluke = SKShapeNode(ellipseOf: CGSize(width: tileSize * 0.2, height: tileSize * 0.1))
        rightFluke.fillColor = color
        rightFluke.strokeColor = .clear
        rightFluke.position = CGPoint(x: tileSize * 0.1, y: 0)
        rightFluke.zRotation = -.pi / 4
        tailNode.addChild(rightFluke)

        return tailNode
    }

    private func addOceanAnimation(to shape: SKShapeNode, baseColor: SKColor) {
        let animationDuration: TimeInterval = 2.5
        let numberOfColors = 8

        var colorActions: [SKAction] = []

        for i in 0...numberOfColors {
            let progress = CGFloat(i) / CGFloat(numberOfColors)
            let hue: CGFloat = 0.5 + (progress * 0.15)
            let saturation: CGFloat = 0.7 + (sin(progress * .pi) * 0.2)
            let brightness: CGFloat = 0.8 + (sin(progress * .pi * 2) * 0.1)

            let oceanColor = SKColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
            let blendedColor = blendColors(oceanColor, with: baseColor, ratio: 0.4)

            let colorAction = SKAction.run { [weak shape] in
                shape?.fillColor = blendedColor
                shape?.strokeColor = blendedColor.withAlphaComponent(0.7)
            }
            let waitAction = SKAction.wait(forDuration: animationDuration / Double(numberOfColors))
            colorActions.append(SKAction.sequence([colorAction, waitAction]))
        }

        let oceanSequence = SKAction.sequence(colorActions)
        let repeatForever = SKAction.repeatForever(oceanSequence)

        shape.run(repeatForever)
    }

    private func blendColors(_ color1: SKColor, with color2: SKColor, ratio: CGFloat) -> SKColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return SKColor(
            red: r1 * (1 - ratio) + r2 * ratio,
            green: g1 * (1 - ratio) + g2 * ratio,
            blue: b1 * (1 - ratio) + b2 * ratio,
            alpha: 1.0
        )
    }
}

// MARK: - Lizard Sprite Renderer

class LizardSpriteRenderer {
    let tileSize: CGFloat
    private let animationHelper: RainbowAnimationHelper

    init(tileSize: CGFloat) {
        self.tileSize = tileSize
        self.animationHelper = RainbowAnimationHelper()
    }

    func createLizardNode(direction: Direction) -> SKNode {
        let lizardNode = SKNode()
        let baseColor = SKColor.systemGreen

        // Lizard body
        let body = SKSpriteNode(color: baseColor, size: CGSize(width: tileSize * 0.5, height: tileSize * 0.7))
        body.alpha = 0.9
        lizardNode.addChild(body)

        // Lizard head
        let head = SKSpriteNode(color: baseColor, size: CGSize(width: tileSize * 0.3, height: tileSize * 0.25))
        head.position = CGPoint(x: 0, y: tileSize * 0.35)
        head.alpha = 0.95
        lizardNode.addChild(head)

        // Eyes
        let leftEye = SKShapeNode(circleOfRadius: tileSize * 0.05)
        leftEye.fillColor = .black
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -tileSize * 0.08, y: tileSize * 0.4)
        lizardNode.addChild(leftEye)

        let rightEye = SKShapeNode(circleOfRadius: tileSize * 0.05)
        rightEye.fillColor = .black
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: tileSize * 0.08, y: tileSize * 0.4)
        lizardNode.addChild(rightEye)

        // Tail
        let tail = SKSpriteNode(color: baseColor.withAlphaComponent(0.7), size: CGSize(width: tileSize * 0.15, height: tileSize * 0.4))
        tail.position = CGPoint(x: 0, y: -tileSize * 0.4)
        lizardNode.addChild(tail)

        // Legs
        let legColor = baseColor.withAlphaComponent(0.6)

        let frontLeftLeg = SKSpriteNode(color: legColor, size: CGSize(width: tileSize * 0.2, height: tileSize * 0.08))
        frontLeftLeg.position = CGPoint(x: -tileSize * 0.25, y: tileSize * 0.15)
        frontLeftLeg.zRotation = 0.3
        lizardNode.addChild(frontLeftLeg)

        let frontRightLeg = SKSpriteNode(color: legColor, size: CGSize(width: tileSize * 0.2, height: tileSize * 0.08))
        frontRightLeg.position = CGPoint(x: tileSize * 0.25, y: tileSize * 0.15)
        frontRightLeg.zRotation = -0.3
        lizardNode.addChild(frontRightLeg)

        let backLeftLeg = SKSpriteNode(color: legColor, size: CGSize(width: tileSize * 0.2, height: tileSize * 0.08))
        backLeftLeg.position = CGPoint(x: -tileSize * 0.25, y: -tileSize * 0.15)
        backLeftLeg.zRotation = -0.3
        lizardNode.addChild(backLeftLeg)

        let backRightLeg = SKSpriteNode(color: legColor, size: CGSize(width: tileSize * 0.2, height: tileSize * 0.08))
        backRightLeg.position = CGPoint(x: tileSize * 0.25, y: -tileSize * 0.15)
        backRightLeg.zRotation = 0.3
        lizardNode.addChild(backRightLeg)

        // Add rainbow animations
        animationHelper.addRainbowAnimation(to: body, phaseOffset: 0)
        animationHelper.addRainbowAnimation(to: head, phaseOffset: 0.1)
        animationHelper.addRainbowAnimation(to: tail, phaseOffset: 0.2)
        animationHelper.addRainbowAnimation(to: frontLeftLeg, phaseOffset: 0.3)
        animationHelper.addRainbowAnimation(to: frontRightLeg, phaseOffset: 0.35)
        animationHelper.addRainbowAnimation(to: backLeftLeg, phaseOffset: 0.4)
        animationHelper.addRainbowAnimation(to: backRightLeg, phaseOffset: 0.45)

        // Add idle animation
        let bobUp = SKAction.moveBy(x: 0, y: 2, duration: 0.5)
        let bobDown = SKAction.moveBy(x: 0, y: -2, duration: 0.5)
        bobUp.timingMode = .easeInEaseOut
        bobDown.timingMode = .easeInEaseOut
        let bobSequence = SKAction.sequence([bobUp, bobDown])
        let bobForever = SKAction.repeatForever(bobSequence)
        lizardNode.run(bobForever)

        lizardNode.zRotation = CGFloat(direction.angle)

        return lizardNode
    }
}
