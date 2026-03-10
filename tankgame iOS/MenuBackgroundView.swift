//
//  MenuBackgroundView.swift
//  Tank Game iOS
//
//  Animated 8-bit style grid background for the main menu.
//

import UIKit

class MenuBackgroundView: UIView {
    
    // Grid properties
    private let gridSize: Int = 16
    private var cellSize: CGFloat = 0
    private var gridCells: [[UIView]] = []
    
    // Animation properties
    private var displayLink: CADisplayLink?
    private var animationTime: TimeInterval = 0
    private let paletteCount: Int
    
    // 8-bit color palette - classic retro colors
    private let palette: [UIColor] = [
        UIColor(red: 0.08, green: 0.12, blue: 0.18, alpha: 1.0),  // Dark blue-gray (base)
        UIColor(red: 0.12, green: 0.18, blue: 0.26, alpha: 1.0),  // Slightly lighter
        UIColor(red: 0.16, green: 0.24, blue: 0.34, alpha: 1.0),  // Medium
        UIColor(red: 0.20, green: 0.30, blue: 0.42, alpha: 1.0),  // Lighter
        UIColor(red: 0.10, green: 0.28, blue: 0.38, alpha: 1.0),  // Cyan tint
    ]
    
    override init(frame: CGRect) {
        paletteCount = palette.count
        super.init(frame: frame)
        setupBackground()
    }
    
    required init?(coder: NSCoder) {
        paletteCount = palette.count
        super.init(coder: coder)
        setupBackground()
    }
    
    private func setupBackground() {
        backgroundColor = palette[0]
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Recalculate cell size when view bounds change
        if bounds.width > 0 && bounds.height > 0 {
            cellSize = max(bounds.width, bounds.height) / CGFloat(gridSize)
            setupGrid()
        }
    }
    
    private func setupGrid() {
        // Remove existing cells
        gridCells.forEach { row in
            row.forEach { $0.removeFromSuperview() }
        }
        gridCells.removeAll()
        
        // Create grid cells
        for row in 0..<gridSize {
            var rowCells: [UIView] = []
            for col in 0..<gridSize {
                let cell = UIView()
                cell.backgroundColor = palette[0]
                cell.layer.borderWidth = 0.5
                cell.layer.borderColor = UIColor(white: 0.25, alpha: 0.3).cgColor
                
                let x = CGFloat(col) * cellSize
                let y = CGFloat(row) * cellSize
                cell.frame = CGRect(x: x, y: y, width: cellSize, height: cellSize)
                
                addSubview(cell)
                rowCells.append(cell)
            }
            gridCells.append(rowCells)
        }
    }
    
    func startAnimating() {
        stopAnimating()
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stopAnimating() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateAnimation() {
        guard let displayLink = displayLink else { return }
        
        // Use actual frame duration for accurate timing
        animationTime += displayLink.duration
        
        // Calculate center once per frame
        let centerRow = Double(gridSize / 2)
        let centerCol = Double(gridSize / 2)
        
        // Update grid colors directly without animation for performance
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                // Calculate distance from center
                let distance = hypot(Double(row) - centerRow, Double(col) - centerCol)
                
                // Wave effect from center
                let wave = sin(distance * 0.4 - animationTime * 1.5) * 0.5 + 0.5
                
                // Diagonal scanning effect
                let diagonal = Double(row + col) / Double(gridSize * 2)
                let scan = sin((diagonal + animationTime * 0.25) * Double.pi * 2) * 0.4 + 0.5
                
                // Pulsing center effect (reuse distance)
                let pulse = sin(distance * 0.2 - animationTime * 1.8) * 0.3 + 0.5
                
                // Combine all effects
                let combined = (wave * 0.5 + scan * 0.3 + pulse * 0.2)
                
                // Map to palette index (using cached count)
                let paletteIndex = min(Int(combined * Double(paletteCount)), paletteCount - 1)
                
                // Update cell color (bounds already guaranteed by setupGrid)
                gridCells[row][col].backgroundColor = palette[paletteIndex]
            }
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if window != nil {
            startAnimating()
        } else {
            stopAnimating()
        }
    }
    
    deinit {
        stopAnimating()
    }
}
