//
//  HomeViewModel.swift
//
//
//  Created by Vadim Marchenko on 09.04.2024.
//

import Foundation
import Domain
import Core
import Combine

///
/// Optional:
/// Lack of documentation here.
/// I need some time to understand why we need this `typealias` here
/// Also, `import Domain` -> This is a compiled package.
/// It would be great to have a bit of documentation, how everything is working here to make reviewing a bit easier.
///

typealias Category = Domain.Category

final class HomeViewModel: ViewModel {
    
    // MARK: - Properties
    typealias DataSource = [SectionModel<Home.Section, Home.Item>]

    private unowned var templatesRepository: TemplatesRepository
    private(set) var sectionCanBeDeletedDict: [Home.Section: Bool] = [:]
    @Published var dataSource: DataSource = []
    var cancellables = Set<AnyCancellable>()
    let logger = AppLogger.homeFeature
    
    // MARK: - Init
    init(templatesRepository: TemplatesRepository) {
        self.templatesRepository = templatesRepository
    }
    
    // MARK: - Public methods
    func fetchData() async throws {
        var promotions: [Promotion] = []
        var categories: [Category] = []
        var movies: [Asset] = []
        var liveChannels: [Asset] = []
        var epg: [Asset] = []
        
        async let categoriesTask = templatesRepository.fetchCategories()
        async let contentGroupsTask = templatesRepository.fetchContentGroups()
        async let promotionsTask = templatesRepository.fetchPromotions()
        
        let (promotionsResponse, categoriesResponse, contentGroupsResponse) = try await (promotionsTask, categoriesTask, contentGroupsTask)
        
        categories = categoriesResponse
        promotions = promotionsResponse
        
        ///
        /// Required:
        /// Not all requirements are met.
        /// You filter all groups and show only one for one type via key in sectionCanBeDeletedDict
        /// But there was no requirements to do so.
        /// You need to display all content groups, so better strategy was to use id for key, not type
        ///
        
        contentGroupsResponse.forEach { group in
            switch group.type {
            case [.movie], [.series]:
                sectionCanBeDeletedDict[.movie] = group.canBeDeleted
                movies.append(contentsOf: group.assets)
            case [.liveChannel]:
                liveChannels.append(contentsOf: group.assets)
                sectionCanBeDeletedDict[.liveChannel] = group.canBeDeleted
            case [.epg]:
                epg.append(contentsOf: group.assets)
                sectionCanBeDeletedDict[.epg] = group.canBeDeleted
            default:
                break
            }
        }
        let content = ContentModel(promotions: promotions,
                                   categories: categories,
                                   movies: movies,
                                   liveChannels: liveChannels,
                                   epg: epg)
        updateDataSource(with: content)
    }
    
    // MARK: - Private methods
    private func updateDataSource(with content: ContentModel) {
        var dataSource = DataSource()
        dataSource.append(contentsOf: [
            .init(section: .promotion, items: content.promotions.map { .promotion($0) }),
            .init(section: .category, items: content.categories.map { .category($0) }),
            .init(section: .movie, items: content.movies.map { .movie($0) }),
            .init(section: .liveChannel, items: content.liveChannels.map { .liveChannel($0) }),
            .init(section: .epg, items: content.epg.map { .epg($0) }),
        ])
        self.dataSource = dataSource
    }
}
