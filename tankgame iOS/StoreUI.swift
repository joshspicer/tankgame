//
//  StoreUI.swift
//  tankgame iOS
//
//  Store interface for purchasing tank skins
//

import UIKit

/// Manages the store user interface for purchasing tank skins
class StoreUI {
    // UI Elements
    private(set) var storeView: UIView!
    private(set) var titleLabel: UILabel!
    private(set) var closeButton: UIButton!
    private(set) var restoreButton: UIButton!
    private(set) var scrollView: UIScrollView!
    private(set) var contentStack: UIStackView!
    
    // Callbacks
    var onCloseTapped: (() -> Void)?
    var onRestoreTapped: (() -> Void)?
    var onPurchaseTapped: ((TankSkinProduct) -> Void)?
    var onSelectTapped: ((TankSkinProduct?) -> Void)?
    
    func setup(in parentView: UIView) {
        // Create store view overlay
        storeView = UIView(frame: parentView.bounds)
        storeView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.97)
        storeView.isHidden = true
        parentView.addSubview(storeView)
        
        // Title
        titleLabel = UILabel()
        titleLabel.text = "🛒 Tank Store"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        storeView.addSubview(titleLabel)
        
        // Close button
        closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 28, weight: .bold)
        closeButton.setTitleColor(.label, for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        storeView.addSubview(closeButton)
        
        // Restore purchases button
        restoreButton = UIButton(type: .system)
        restoreButton.setTitle("Restore Purchases", for: .normal)
        restoreButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        restoreButton.translatesAutoresizingMaskIntoConstraints = false
        restoreButton.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
        storeView.addSubview(restoreButton)
        
        // Scroll view for products
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        storeView.addSubview(scrollView)
        
        // Content stack for product cards
        contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        setupConstraints()
        populateProducts()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: storeView.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: storeView.centerXAnchor),
            
            closeButton.topAnchor.constraint(equalTo: storeView.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: storeView.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            restoreButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            restoreButton.centerXAnchor.constraint(equalTo: storeView.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: restoreButton.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: storeView.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: storeView.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: storeView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func populateProducts() {
        // Add default skin option
        let defaultCard = createProductCard(
            title: "🎯 Default Skin",
            description: "The classic rainbow tank",
            price: "Free",
            isPurchased: true,
            isDefault: true
        )
        contentStack.addArrangedSubview(defaultCard)
        
        // Add purchasable skins
        for product in TankSkinProduct.allCases {
            let card = createProductCard(
                title: "\(product.emoji) \(product.displayName)",
                description: product.description,
                price: product.price,
                isPurchased: false,
                isDefault: false,
                product: product
            )
            contentStack.addArrangedSubview(card)
        }
    }
    
    private func createProductCard(title: String, description: String, price: String, isPurchased: Bool, isDefault: Bool, product: TankSkinProduct? = nil) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        // Description
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(descLabel)
        
        // Action button
        let actionButton = UIButton(type: .system)
        actionButton.layer.cornerRadius = 8
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        if isDefault {
            actionButton.setTitle("Select", for: .normal)
            actionButton.backgroundColor = .systemBlue
            actionButton.setTitleColor(.white, for: .normal)
            actionButton.addAction(UIAction { [weak self] _ in
                self?.onSelectTapped?(nil)
            }, for: .touchUpInside)
        } else if let product = product {
            actionButton.setTitle(price, for: .normal)
            actionButton.backgroundColor = .systemGreen
            actionButton.setTitleColor(.white, for: .normal)
            actionButton.addAction(UIAction { [weak self] _ in
                self?.onPurchaseTapped?(product)
            }, for: .touchUpInside)
        }
        
        card.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -12),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -12),
            
            actionButton.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            actionButton.widthAnchor.constraint(equalToConstant: 80),
            actionButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        return card
    }
    
    func show() {
        storeView.isHidden = false
        storeView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.storeView.alpha = 1
        }
        refreshProductStates()
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3) {
            self.storeView.alpha = 0
        } completion: { _ in
            self.storeView.isHidden = true
        }
    }
    
    /// Refresh product card states based on purchases
    func refreshProductStates() {
        let storeManager = StoreKitManager.shared
        
        // Iterate through content stack views (skip first one which is default)
        for (index, view) in contentStack.arrangedSubviews.enumerated() {
            guard index > 0, index - 1 < TankSkinProduct.allCases.count else { continue }
            let product = TankSkinProduct.allCases[index - 1]
            
            // Find the action button in the card
            if let actionButton = view.subviews.compactMap({ $0 as? UIButton }).first {
                if storeManager.isPurchased(product) {
                    actionButton.setTitle("Select", for: .normal)
                    actionButton.backgroundColor = .systemBlue
                    
                    // Create action with unique identifier - UIButton deduplicates by identifier
                    let actionId = UIAction.Identifier("select_\(product.rawValue)")
                    let selectAction = UIAction(identifier: actionId) { [weak self] _ in
                        self?.onSelectTapped?(product)
                    }
                    // Remove previous action with same identifier if exists, then add new one
                    actionButton.removeAction(identifiedBy: actionId, for: .touchUpInside)
                    actionButton.addAction(selectAction, for: .touchUpInside)
                    
                    // Highlight if selected
                    if storeManager.selectedSkin == product {
                        view.layer.borderWidth = 3
                        view.layer.borderColor = UIColor.systemBlue.cgColor
                    } else {
                        view.layer.borderWidth = 0
                    }
                }
            }
        }
        
        // Handle default skin selection highlight
        if let defaultCard = contentStack.arrangedSubviews.first {
            if storeManager.selectedSkin == nil {
                defaultCard.layer.borderWidth = 3
                defaultCard.layer.borderColor = UIColor.systemBlue.cgColor
            } else {
                defaultCard.layer.borderWidth = 0
            }
        }
    }
    
    @objc private func closeButtonTapped() {
        onCloseTapped?()
    }
    
    @objc private func restoreButtonTapped() {
        onRestoreTapped?()
    }
}
