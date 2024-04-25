//
//  HomePromoPagingSectionFooterView.swift
//
//
//  Created by Vadim Marchenko on 14.04.2024.
//

import Foundation
import UIKit
import Combine

// To resolve this issue I've used an aritcle: https://nemecek.be/blog/141/how-to-show-page-indicator-with-compositional-layout#preparing-paging-control

/// 
/// We also used simillar workaround
///

final class HomePromoPagingSectionFooterView: UICollectionReusableView {
    
    // MARK: - Properties
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.isUserInteractionEnabled = true
        control.currentPageIndicatorTintColor = .white
        control.pageIndicatorTintColor = .white.withAlphaComponent(0.25)
        control.isUserInteractionEnabled = false
        return control
    }()

    private var pagingInfoToken: AnyCancellable?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        pagingInfoToken?.cancel()
        pagingInfoToken = nil
    }

    // MARK: - Public methods
    func configure(with numberOfPages: Int) {
        pageControl.numberOfPages = numberOfPages
    }

    func subscribeTo(subject: PassthroughSubject<PagingInfo, Never>, for section: Int) {
        pagingInfoToken = subject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pagingInfo in
                self?.pageControl.currentPage = pagingInfo.currentPage
            }
    }

    // MARK: - Private methods
    private func setupUI() {
        backgroundColor = .clear
        addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.centerYAnchor.constraint(equalTo: centerYAnchor, constant: HomeConstant.Footer.bottomPadding)
        ])
    }
    
}
