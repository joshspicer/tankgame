//
//  StoreUI.swift
//  tankgame iOS
//
//  Created by jospicer on 10/28/25.
//

import UIKit

/// Manages the in-game store user interface
class StoreUI {
    
    // UI Elements
    private(set) var storeView: UIView!
    private(set) var closeButton: UIButton!
    private(set) var coinsLabel: UILabel!
    private(set) var scrollView: UIScrollView!
    private(set) var contentView: UIView!
    
    // Section views
    private var skinsSection: UIView!
    private var coinsSection: UIView!
    
    // Callbacks
    var onCloseTapped: (() -> Void)?
    var onSkinSelected: ((TankSkin) -> Void)?
    var onSkinPurchased: ((TankSkin) -> Void)?
    var onCoinPackageTapped: ((String) -> Void)?
    
    // Store reference
    private let storeManager = StoreManager.shared
    
    func setup(in parentView: UIView) {
        // Create store view
        storeView = UIView(frame: parentView.bounds)
        storeView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.97)
        storeView.isHidden = true
        parentView.addSubview(storeView)
        
        // Store title
        let titleLabel = UILabel()
        titleLabel.text = "🏪 Tank Store"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        storeView.addSubview(titleLabel)
        
        // Coins display
        coinsLabel = UILabel()
        updateCoinsDisplay()
        coinsLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        coinsLabel.textAlignment = .center
        coinsLabel.textColor = .systemYellow
        coinsLabel.translatesAutoresizingMaskIntoConstraints = false
        storeView.addSubview(coinsLabel)
        
        // Close button using SF Symbols for better accessibility
        closeButton = UIButton(type: .system)
        let closeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let closeImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: closeConfig)
        closeButton.setImage(closeImage, for: .normal)
        closeButton.tintColor = .label
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.accessibilityLabel = "Close store"
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        storeView.addSubview(closeButton)
        
        // Scroll view for content
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        storeView.addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        setupConstraints(titleLabel: titleLabel)
        setupSections()
    }
    
    private func setupConstraints(titleLabel: UILabel) {
        NSLayoutConstraint.activate([
            // Close button - top right
            closeButton.topAnchor.constraint(equalTo: storeView.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: storeView.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: storeView.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: storeView.centerXAnchor),
            
            // Coins label
            coinsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            coinsLabel.centerXAnchor.constraint(equalTo: storeView.centerXAnchor),
            
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: coinsLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: storeView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: storeView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: storeView.safeAreaLayoutGuide.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupSections() {
        // Create skins section
        skinsSection = createSection(title: "🎨 Tank Skins")
        contentView.addSubview(skinsSection)
        
        // Create coin packages section
        coinsSection = createSection(title: "💰 Coin Packages")
        contentView.addSubview(coinsSection)
        
        NSLayoutConstraint.activate([
            skinsSection.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            skinsSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            skinsSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            coinsSection.topAnchor.constraint(equalTo: skinsSection.bottomAnchor, constant: 30),
            coinsSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            coinsSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            coinsSection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
        
        populateSkins()
        populateCoinPackages()
    }
    
    private func createSection(title: String) -> UIView {
        let section = UIView()
        section.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        section.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: section.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: section.leadingAnchor)
        ])
        
        return section
    }
    
    private func populateSkins() {
        var previousView: UIView? = skinsSection.subviews.first
        let skins = TankSkin.allSkins
        
        for skin in skins {
            let skinCard = createSkinCard(skin: skin)
            skinsSection.addSubview(skinCard)
            
            NSLayoutConstraint.activate([
                skinCard.topAnchor.constraint(equalTo: previousView?.bottomAnchor ?? skinsSection.topAnchor, constant: 15),
                skinCard.leadingAnchor.constraint(equalTo: skinsSection.leadingAnchor),
                skinCard.trailingAnchor.constraint(equalTo: skinsSection.trailingAnchor),
                skinCard.heightAnchor.constraint(equalToConstant: 80)
            ])
            
            previousView = skinCard
        }
        
        if let lastView = previousView {
            lastView.bottomAnchor.constraint(equalTo: skinsSection.bottomAnchor).isActive = true
        }
    }
    
    private func createSkinCard(skin: TankSkin) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        card.tag = skin.id.hashValue
        
        // Color preview
        let colorPreview = UIView()
        colorPreview.backgroundColor = skin.primaryColor
        colorPreview.layer.cornerRadius = 20
        if skin.hasGlowEffect {
            colorPreview.layer.shadowColor = skin.primaryColor.cgColor
            colorPreview.layer.shadowRadius = 8
            colorPreview.layer.shadowOpacity = 0.8
            colorPreview.layer.shadowOffset = .zero
        }
        colorPreview.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(colorPreview)
        
        // Name label
        let nameLabel = UILabel()
        nameLabel.text = skin.name
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(nameLabel)
        
        // Description label
        let descLabel = UILabel()
        descLabel.text = skin.description
        descLabel.font = .systemFont(ofSize: 12)
        descLabel.textColor = .secondaryLabel
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(descLabel)
        
        // Action button
        let actionButton = UIButton(type: .system)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.layer.cornerRadius = 8
        actionButton.accessibilityIdentifier = skin.id
        
        let isOwned = storeManager.isSkinOwned(skin.id)
        let isSelected = storeManager.selectedSkinId == skin.id
        
        if isSelected {
            actionButton.setTitle("✓ Selected", for: .normal)
            actionButton.backgroundColor = .systemGreen
            actionButton.setTitleColor(.white, for: .normal)
        } else if isOwned {
            actionButton.setTitle("Select", for: .normal)
            actionButton.backgroundColor = .systemBlue
            actionButton.setTitleColor(.white, for: .normal)
            actionButton.addTarget(self, action: #selector(selectSkinTapped(_:)), for: .touchUpInside)
        } else {
            actionButton.setTitle("🪙 \(skin.price)", for: .normal)
            actionButton.backgroundColor = .systemYellow
            actionButton.setTitleColor(.black, for: .normal)
            actionButton.addTarget(self, action: #selector(purchaseSkinTapped(_:)), for: .touchUpInside)
        }
        
        actionButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        card.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            colorPreview.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            colorPreview.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            colorPreview.widthAnchor.constraint(equalToConstant: 40),
            colorPreview.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: colorPreview.trailingAnchor, constant: 16),
            
            descLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -8),
            
            actionButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            actionButton.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 100),
            actionButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        return card
    }
    
    private func populateCoinPackages() {
        var previousView: UIView? = coinsSection.subviews.first
        
        for package in StoreManager.coinPackages {
            let packageCard = createCoinPackageCard(package: package)
            coinsSection.addSubview(packageCard)
            
            NSLayoutConstraint.activate([
                packageCard.topAnchor.constraint(equalTo: previousView?.bottomAnchor ?? coinsSection.topAnchor, constant: 15),
                packageCard.leadingAnchor.constraint(equalTo: coinsSection.leadingAnchor),
                packageCard.trailingAnchor.constraint(equalTo: coinsSection.trailingAnchor),
                packageCard.heightAnchor.constraint(equalToConstant: 60)
            ])
            
            previousView = packageCard
        }
        
        if let lastView = previousView {
            lastView.bottomAnchor.constraint(equalTo: coinsSection.bottomAnchor).isActive = true
        }
    }
    
    private func createCoinPackageCard(package: (id: String, coins: Int, price: String)) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        
        // Coin icon
        let coinIcon = UILabel()
        coinIcon.text = "🪙"
        coinIcon.font = .systemFont(ofSize: 28)
        coinIcon.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(coinIcon)
        
        // Amount label
        let amountLabel = UILabel()
        amountLabel.text = "\(package.coins) TankCoins"
        amountLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(amountLabel)
        
        // Buy button
        let buyButton = UIButton(type: .system)
        buyButton.setTitle(package.price, for: .normal)
        buyButton.backgroundColor = .systemGreen
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        buyButton.layer.cornerRadius = 8
        buyButton.accessibilityIdentifier = package.id
        buyButton.addTarget(self, action: #selector(buyCoinsTapped(_:)), for: .touchUpInside)
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(buyButton)
        
        NSLayoutConstraint.activate([
            coinIcon.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            coinIcon.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            
            amountLabel.leadingAnchor.constraint(equalTo: coinIcon.trailingAnchor, constant: 12),
            amountLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            
            buyButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            buyButton.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            buyButton.widthAnchor.constraint(equalToConstant: 80),
            buyButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        return card
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        onCloseTapped?()
    }
    
    @objc private func selectSkinTapped(_ sender: UIButton) {
        guard let skinId = sender.accessibilityIdentifier,
              let skin = TankSkin.skin(withId: skinId) else { return }
        onSkinSelected?(skin)
        refreshSkinCards()
    }
    
    @objc private func purchaseSkinTapped(_ sender: UIButton) {
        guard let skinId = sender.accessibilityIdentifier,
              let skin = TankSkin.skin(withId: skinId) else { return }
        onSkinPurchased?(skin)
    }
    
    @objc private func buyCoinsTapped(_ sender: UIButton) {
        guard let packageId = sender.accessibilityIdentifier else { return }
        onCoinPackageTapped?(packageId)
    }
    
    // MARK: - UI Updates
    
    func updateCoinsDisplay() {
        coinsLabel.text = "🪙 \(storeManager.coins) TankCoins"
    }
    
    func refreshSkinCards() {
        // Remove existing skin cards (keep the title label which is first)
        let titleLabel = skinsSection.subviews.first
        for subview in skinsSection.subviews where subview !== titleLabel {
            subview.removeFromSuperview()
        }
        populateSkins()
        updateCoinsDisplay()
    }
    
    func show() {
        refreshSkinCards()
        storeView.isHidden = false
    }
    
    func hide() {
        storeView.isHidden = true
    }
}
