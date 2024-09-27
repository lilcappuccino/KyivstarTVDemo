//
//  DetailsViewController.swift
//
//
//  Created by Vadim Marchenko on 13.04.2024.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - DetailsViewController
final class DetailsViewController: UIViewController {
    
    private var detailView: DetailsView
    weak var coordinatorDelegate: CoordinatorLifeCycle?
    
    init(detailView: DetailsView) {
        self.detailView = detailView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        injectSwiftUIView()
        if let interactivePopGestureRecognizer = navigationController?.interactivePopGestureRecognizer {
               interactivePopGestureRecognizer.delegate = self
           }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinatorDelegate?.finish()
    }
    
    func injectSwiftUIView() {
        let hostingController = UIHostingController(rootView: detailView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .white
    
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    deinit {
        /// Just regular check for leaks
        print("DetailsViewController deinited")
        /// Leak check: Passed, no leaks.
    }
}

extension DetailsViewController: UIGestureRecognizerDelegate {
    
    ///
    /// Required:
    /// You created a `interactivePopGestureRecognizer` but forgot to add a back button
    ///
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Check if the current view controller is the root of the navigation stack
        if navigationController?.viewControllers.count ?? 0 > 1 {
            return true
        }
        return false
    }
}
