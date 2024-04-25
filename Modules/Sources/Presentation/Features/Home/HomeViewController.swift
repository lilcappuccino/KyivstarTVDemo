//
//  HomeViewController.swift
//
//
//  Created by Vadim Marchenko on 09.04.2024.
//

import Foundation
import UIKit
import Core
import Combine

typealias DataSource = UICollectionViewDiffableDataSource<Home.Section, Home.Item>
typealias Snapshot = NSDiffableDataSourceSnapshot<Home.Section, Home.Item>

final class HomeViewController: UIViewController, Viewable {
    
    // MARK: - Properties
    let viewModel: HomeViewModel
    let logger = AppLogger.homeFeature
    weak var navigator: (any Navigator<HomeDestination>)?
    private let pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()
    
    // MARK: - Init
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    private var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.color = ColorAssets.action
        return activityIndicatorView
    }()
    
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    private let lauotySectionFactory = HomeLayoutSectionFactory()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
        
        viewModel.$dataSource
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dataSource in
                var snapshot = Snapshot()
                for sectionModel in dataSource {
                    snapshot.appendSections([sectionModel.section])
                    snapshot.appendItems(sectionModel.items, toSection: sectionModel.section)
                }
                self?.dataSource?.apply(snapshot)
            }
            .store(in: &viewModel.cancellables)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Private methods
    private func fetchData() {
        activityIndicatorView.startAnimating()
        collectionView.backgroundColor = .clear
        Task(priority: .high) {
            do {
                ///
                /// Required:
                /// There was a requirement to show user any loaded information.
                /// Here we see that if any of request fails -> all previously loaded info will be lost in catch case.
                ///
                try await viewModel.fetchData()
            } catch let error {
                viewModel.logger.error("\(error.localizedDescription)")
                showErrorAlert()
            }
            activityIndicatorView.stopAnimating()
            collectionView.backgroundColor = .white
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Упс..",
                                      message: "Не вдалось отримати дані",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Повторити",
                                      style: .default,
                                      handler: { [weak self] _ in
            self?.fetchData()
        }))
        alert.addAction(UIAlertAction(title: "Закрити", style: .destructive))
        present(alert, animated: true)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        setupCollectionView()
        setupHeader()
        setupDataSource()
        setupConstraints()
        registerCells()
    }
    
    private func setupCollectionView() {
        lauotySectionFactory.delegate = self
        let layout = UICollectionViewCompositionalLayout { [unowned self] sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            
            let section = dataSource.snapshot().sectionIdentifiers[sectionIndex]
            // Naming confuse
            return self.lauotySectionFactory.build(for: section)
        }
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
    }
    
    private func setupDataSource() {
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .category(let category):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCategoryCollectionCell.className, for: indexPath) as! HomeCategoryCollectionCell
                cell.configure(imageURL: category.imageURL, title: category.name)
                return cell
            case .epg(let epg):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeEpgCollectionCell.className, for: indexPath) as! HomeEpgCollectionCell
                cell.configure(asset: epg)
                return cell
            case .liveChannel(let liveChannel):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeLiveChannelCollectionCell.className, for: indexPath) as! HomeLiveChannelCollectionCell
                cell.configure(asset: liveChannel)
                return cell
            case .promotion(let promotion):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePromotionCollectionCell.className, for: indexPath) as! HomePromotionCollectionCell
                cell.configure(imageURL: promotion.imageURL)
                return cell
            case .movie(let movie):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeMovieCollectionCell.className, for: indexPath) as! HomeMovieCollectionCell
                cell.configure(asset: movie)
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { [unowned self] collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                return setupSectionHeader(indexPath: indexPath)
            } else {
                return setupSectionFooter(indexPath: indexPath)
            }
        }
    }
    
    private func setupSectionHeader(indexPath: IndexPath) -> HomeSectionHeaderReusableView {
        let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        let header: HomeSectionHeaderReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                                                    withReuseIdentifier: HomeSectionHeaderReusableView.className,
                                                                                                    for: indexPath) as! HomeSectionHeaderReusableView
        let canBeDeleted = viewModel.sectionCanBeDeletedDict[section] ?? true
        header.configure(title: section.title, isCanDelete: canBeDeleted) { [weak self] in
            self?.deleteSection(section: section)
        }
        return header
    }
    
    private func setupSectionFooter(indexPath: IndexPath) -> HomePromoPagingSectionFooterView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                                     withReuseIdentifier: HomePromoPagingSectionFooterView.className,
                                                                     for: indexPath) as! HomePromoPagingSectionFooterView
        
        let itemCount = dataSource.snapshot().numberOfItems(inSection: .promotion)
        footer.configure(with: itemCount)
        footer.subscribeTo(subject: pagingInfoSubject, for: indexPath.section)
        
        return footer
    }
    
    private func deleteSection(section: Home.Section) {
        logger.info("Deleting setion: \(section.title)")
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteSections([section])
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    private func registerCells() {
        collectionView.register(HomeCategoryCollectionCell.self, forCellWithReuseIdentifier: HomeCategoryCollectionCell.className)
        collectionView.register(HomeEpgCollectionCell.self, forCellWithReuseIdentifier: HomeEpgCollectionCell.className)
        collectionView.register(HomeLiveChannelCollectionCell.self, forCellWithReuseIdentifier: HomeLiveChannelCollectionCell.className)
        collectionView.register(HomePromotionCollectionCell.self, forCellWithReuseIdentifier: HomePromotionCollectionCell.className)
        collectionView.register(HomeMovieCollectionCell.self, forCellWithReuseIdentifier: HomeMovieCollectionCell.className)
        collectionView.register(HomeSectionHeaderReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HomeSectionHeaderReusableView.className)
        collectionView.register(HomePromoPagingSectionFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: HomePromoPagingSectionFooterView.className)
    }
    
    private func setupHeader() {
        let imageView = UIImageView(image: ImageAssets.logo)
        let imageHeight = imageView.frame.height
        imageView.contentMode = .center
        imageView.frame = CGRectMake(0, -imageHeight, self.collectionView.frame.size.width, HomeConstant.Header.imagePadding)
        collectionView.addSubview(imageView)
        collectionView.contentInset = UIEdgeInsets(top: imageHeight, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        setupActivityIndicatorConstraints()
        setupCollectionViewConstraints()
    }
    
    private func setupActivityIndicatorConstraints() {
        view.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupCollectionViewConstraints() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigator?.navigate(to: .details)
    }
}

// MARK: - HomeLayoutSectionFactoryDelegate
extension HomeViewController: HomeLayoutSectionFactoryDelegate {
    func currentPromotionSection(offsetX: CGFloat) {
        let page = round(offsetX / self.view.bounds.width)
        self.pagingInfoSubject.send(PagingInfo(currentPage: Int(page)))
    }
    
}
