//
//  StoreUI.swift
//  tankgame iOS
//
//  Store interface for microtransactions
//

import UIKit
import StoreKit

/// Manages the store user interface for in-app purchases
class StoreUI {
    
    // UI Elements
    private var containerView: UIView!
    private var scrollView: UIScrollView!
    private var contentView: UIStackView!
    private var titleLabel: UILabel!
    private var coinBalanceLabel: UILabel!
    private var closeButton: UIButton!
    private var restoreButton: UIButton!
    private var loadingIndicator: UIActivityIndicatorView!
    
    // Callbacks
    var onClose: (() -> Void)?
    var onPurchaseComplete: (() -> Void)?
    
    // Store manager reference
    private let storeManager = StoreKitManager.shared
    
    /// Setup the store UI in a parent view
    func setup(in parentView: UIView) {
        // Container view
        containerView = UIView(frame: parentView.bounds)
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        containerView.isHidden = true
        parentView.addSubview(containerView)
        
        // Close button
        closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 28, weight: .bold)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        containerView.addSubview(closeButton)
        
        // Title
        titleLabel = UILabel()
        titleLabel.text = "🛒 STORE"
        titleLabel.font = .systemFont(ofSize: 32, weight: .black)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Coin balance
        coinBalanceLabel = UILabel()
        updateCoinBalance()
        coinBalanceLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        coinBalanceLabel.textAlignment = .center
        coinBalanceLabel.textColor = .systemYellow
        coinBalanceLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(coinBalanceLabel)
        
        // Scroll view
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(scrollView)
        
        // Content stack view
        contentView = UIStackView()
        contentView.axis = .vertical
        contentView.spacing = 16
        contentView.alignment = .fill
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Restore button
        restoreButton = UIButton(type: .system)
        restoreButton.setTitle("Restore Purchases", for: .normal)
        restoreButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        restoreButton.setTitleColor(.systemBlue, for: .normal)
        restoreButton.translatesAutoresizingMaskIntoConstraints = false
        restoreButton.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
        containerView.addSubview(restoreButton)
        
        // Loading indicator
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(loadingIndicator)
        
        setupConstraints()
        setupProductViews()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Close button
            closeButton.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Coin balance
            coinBalanceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            coinBalanceLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: coinBalanceLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: restoreButton.topAnchor, constant: -20),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Restore button
            restoreButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            restoreButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    private func setupProductViews() {
        // Add section headers and product cards
        addSectionHeader("🎨 Tank Skins")
        addProductCard(for: .goldTankSkin)
        addProductCard(for: .rainbowTankSkin)
        addProductCard(for: .camo)
        
        addSectionHeader("⚡️ Power-Ups")
        addProductCard(for: .speedBoost)
        addProductCard(for: .extraAmmo)
        
        addSectionHeader("💰 Coin Packs")
        addProductCard(for: .coinPack100)
        addProductCard(for: .coinPack500)
        addProductCard(for: .coinPack1000)
    }
    
    private func addSectionHeader(_ title: String) {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIView()
        container.addSubview(label)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        contentView.addArrangedSubview(container)
    }
    
    private func addProductCard(for product: StoreProduct) {
        let cardView = UIView()
        cardView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.2)
        cardView.layer.cornerRadius = 12
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        // Emoji
        let emojiLabel = UILabel()
        emojiLabel.text = product.emoji
        emojiLabel.font = .systemFont(ofSize: 40)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(emojiLabel)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = product.displayName
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)
        
        // Description
        let descriptionLabel = UILabel()
        descriptionLabel.text = product.description
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .lightGray
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(descriptionLabel)
        
        // Buy button
        let buyButton = UIButton(type: .system)
        buyButton.setTitle(getPriceString(for: product), for: .normal)
        buyButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.backgroundColor = storeManager.isPurchased(product) ? .systemGray : .systemGreen
        buyButton.layer.cornerRadius = 8
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        buyButton.tag = StoreProduct.allCases.firstIndex(of: product) ?? 0
        buyButton.addTarget(self, action: #selector(buyButtonTapped(_:)), for: .touchUpInside)
        
        if storeManager.isPurchased(product) {
            buyButton.setTitle("Owned ✓", for: .normal)
            buyButton.isEnabled = false
        }
        
        cardView.addSubview(buyButton)
        
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: 100),
            
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            emojiLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: buyButton.leadingAnchor, constant: -8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: buyButton.leadingAnchor, constant: -8),
            
            buyButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            buyButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            buyButton.widthAnchor.constraint(equalToConstant: 90),
            buyButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        contentView.addArrangedSubview(cardView)
    }
    
    private func getPriceString(for product: StoreProduct) -> String {
        // In a real app, this would come from the StoreKit Product
        // For now, return placeholder prices
        switch product {
        case .goldTankSkin: return "$2.99"
        case .rainbowTankSkin: return "$1.99"
        case .camo: return "$1.99"
        case .speedBoost: return "$0.99"
        case .extraAmmo: return "$0.99"
        case .coinPack100: return "$0.99"
        case .coinPack500: return "$3.99"
        case .coinPack1000: return "$6.99"
        }
    }
    
    private func updateCoinBalance() {
        coinBalanceLabel.text = "💰 \(storeManager.coinBalance) Coins"
    }
    
    // MARK: - Public Methods
    
    /// Show the store UI
    func show() {
        containerView.isHidden = false
        containerView.alpha = 0
        updateCoinBalance()
        
        UIView.animate(withDuration: 0.3) {
            self.containerView.alpha = 1
        }
    }
    
    /// Hide the store UI
    func hide() {
        UIView.animate(withDuration: 0.3) {
            self.containerView.alpha = 0
        } completion: { _ in
            self.containerView.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        hide()
        onClose?()
    }
    
    @objc private func restoreButtonTapped() {
        loadingIndicator.startAnimating()
        
        Task { @MainActor in
            await storeManager.restorePurchases()
            loadingIndicator.stopAnimating()
            refreshProductViews()
        }
    }
    
    @objc private func buyButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < StoreProduct.allCases.count else { return }
        
        let product = StoreProduct.allCases[index]
        
        // Check if already purchased
        if storeManager.isPurchased(product) {
            return
        }
        
        loadingIndicator.startAnimating()
        
        Task { @MainActor in
            do {
                _ = try await storeManager.purchase(product)
                updateCoinBalance()
                refreshProductViews()
                onPurchaseComplete?()
            } catch {
                showAlert(title: "Purchase Failed", message: error.localizedDescription)
            }
            loadingIndicator.stopAnimating()
        }
    }
    
    private func refreshProductViews() {
        // Remove existing views and recreate
        contentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        setupProductViews()
    }
    
    private func showAlert(title: String, message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let viewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
}
