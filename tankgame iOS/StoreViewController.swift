//
//  StoreViewController.swift
//  tankgame iOS
//
//  UIKit wrapper for presenting the store view
//

#if os(iOS)
import UIKit
import SwiftUI
import StoreKit

/// UIKit view controller that wraps the SwiftUI StoreView
class StoreViewController: UIViewController {
    
    // MARK: - Properties
    
    private var hostingController: UIHostingController<StoreView>?
    
    /// Completion handler called when the store is dismissed
    var onDismiss: (() -> Void)?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStoreView()
    }
    
    private func setupStoreView() {
        let storeView = StoreView()
        let hostingController = UIHostingController(rootView: storeView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
        self.hostingController = hostingController
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss?()
    }
}

// MARK: - UIViewController Extension for Presenting Store

extension UIViewController {
    
    /// Present the store view controller modally
    /// - Parameter completion: Optional completion handler called when the store is dismissed
    func presentStore(completion: (() -> Void)? = nil) {
        let storeVC = StoreViewController()
        storeVC.modalPresentationStyle = .pageSheet
        storeVC.onDismiss = completion
        
        if let sheet = storeVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(storeVC, animated: true)
    }
}

// MARK: - Store Button View

/// A reusable button that opens the store when tapped
class StoreButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        var config = UIButton.Configuration.filled()
        config.title = "Store"
        config.image = UIImage(systemName: "cart.fill")
        config.imagePadding = 8
        config.cornerStyle = .medium
        
        configuration = config
        
        addTarget(self, action: #selector(openStore), for: .touchUpInside)
    }
    
    @objc private func openStore() {
        // Find the presenting view controller
        if let viewController = findViewController() {
            viewController.presentStore()
        }
    }
    
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}
#endif
