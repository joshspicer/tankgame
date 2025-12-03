//
//  TankPackSelectionUI.swift
//  tankgame iOS
//
//  UI for selecting and purchasing tank packs
//

import UIKit
import SpriteKit
import StoreKit

/// View controller for tank pack selection
class TankPackSelectionViewController: UIViewController {
    
    // UI Elements
    private var collectionView: UICollectionView!
    private var titleLabel: UILabel!
    private var restoreButton: UIButton!
    private var closeButton: UIButton!
    private var loadingIndicator: UIActivityIndicatorView!
    
    // Data
    private var packs: [TankPack] = TankPack.allPacks
    
    // Store reference for iOS 15+
    @available(iOS 15.0, *)
    private var store: TankPackStore { TankPackStore.shared }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Listen for purchase notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePurchaseCompleted),
            name: .tankPackPurchaseCompleted,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Title
        titleLabel = UILabel()
        titleLabel.text = "🎨 Tank Packs"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Close button
        closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .label
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        // Restore button
        restoreButton = UIButton(type: .system)
        restoreButton.setTitle("Restore Purchases", for: .normal)
        restoreButton.titleLabel?.font = .systemFont(ofSize: 14)
        restoreButton.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)
        restoreButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(restoreButton)
        
        // Loading indicator
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        // Collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        // Collection view
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TankPackCell.self, forCellWithReuseIdentifier: TankPackCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            restoreButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            restoreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: restoreButton.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func restoreTapped() {
        loadingIndicator.startAnimating()
        
        if #available(iOS 15.0, *) {
            Task {
                await store.restorePurchases()
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    collectionView.reloadData()
                }
            }
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    @objc private func handlePurchaseCompleted() {
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension TankPackSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return packs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TankPackCell.identifier, for: indexPath) as! TankPackCell
        let pack = packs[indexPath.item]
        let isOwned = TankPackManager.shared.isPackOwned(pack)
        let isSelected = TankPackManager.shared.selectedPackID == pack.id
        
        var priceString: String? = nil
        if #available(iOS 15.0, *) {
            if let product = store.product(for: pack) {
                priceString = product.displayPrice
            }
        }
        
        cell.configure(with: pack, isOwned: isOwned, isSelected: isSelected, price: priceString)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TankPackSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pack = packs[indexPath.item]
        
        if TankPackManager.shared.isPackOwned(pack) {
            // Select the pack
            TankPackManager.shared.selectPack(pack)
            collectionView.reloadData()
        } else {
            // Purchase the pack
            if #available(iOS 15.0, *) {
                loadingIndicator.startAnimating()
                Task {
                    let success = await store.purchase(pack)
                    await MainActor.run {
                        loadingIndicator.stopAnimating()
                        if success {
                            TankPackManager.shared.selectPack(pack)
                        }
                        collectionView.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TankPackSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 32
        return CGSize(width: width, height: 140)
    }
}

// MARK: - TankPackCell

/// Custom cell for displaying a tank pack
class TankPackCell: UICollectionViewCell {
    static let identifier = "TankPackCell"
    
    private var nameLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var priceLabel: UILabel!
    private var statusLabel: UILabel!
    private var previewView: SKView!
    private var previewScene: SKScene?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        // Preview view for tank
        previewView = SKView()
        previewView.allowsTransparency = true
        previewView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(previewView)
        
        // Name label
        nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        // Description label
        descriptionLabel = UILabel()
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        // Price label
        priceLabel = UILabel()
        priceLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        priceLabel.textColor = .systemBlue
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLabel)
        
        // Status label (selected/owned)
        statusLabel = UILabel()
        statusLabel.font = .systemFont(ofSize: 12, weight: .medium)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            previewView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            previewView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            previewView.widthAnchor.constraint(equalToConstant: 80),
            previewView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            statusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with pack: TankPack, isOwned: Bool, isSelected: Bool, price: String?) {
        nameLabel.text = pack.name
        descriptionLabel.text = pack.description
        
        if isOwned {
            priceLabel.text = "Owned"
            priceLabel.textColor = .systemGreen
        } else if let price = price {
            priceLabel.text = price
            priceLabel.textColor = .systemBlue
        } else {
            priceLabel.text = pack.isPremium ? "Premium" : "Free"
            priceLabel.textColor = pack.isPremium ? .systemOrange : .systemGreen
        }
        
        if isSelected {
            statusLabel.text = "✓ Selected"
            statusLabel.textColor = .systemGreen
            contentView.layer.borderWidth = 2
            contentView.layer.borderColor = UIColor.systemGreen.cgColor
        } else {
            statusLabel.text = isOwned ? "Tap to select" : "Tap to buy"
            statusLabel.textColor = .secondaryLabel
            contentView.layer.borderWidth = 0
        }
        
        // Create preview scene
        setupPreviewScene(with: pack)
    }
    
    private func setupPreviewScene(with pack: TankPack) {
        let scene = SKScene(size: CGSize(width: 80, height: 80))
        scene.backgroundColor = .clear
        scene.scaleMode = .aspectFit
        
        // Create a themed tank preview
        let renderer = ThemedTankSpriteRenderer(tileSize: 40)
        let colors = pack.style.primaryColors
        let color = colors.first?.skColor ?? .blue
        
        let tankNode = renderer.createTankNode(
            color: color,
            direction: .up,
            bodyShape: pack.style.bodyShape,
            barrelStyle: pack.style.barrelStyle,
            animationType: pack.style.animationType
        )
        tankNode.position = CGPoint(x: 40, y: 40)
        scene.addChild(tankNode)
        
        previewView.presentScene(scene)
        previewScene = scene
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        previewScene?.removeAllChildren()
        previewScene = nil
    }
}
