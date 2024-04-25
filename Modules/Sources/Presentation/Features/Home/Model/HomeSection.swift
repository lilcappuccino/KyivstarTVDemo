//
//  HomeSection.swift
//
//
//  Created by Vadim Marchenko on 10.04.2024.
//

import Foundation
import Domain

// MARK: - HomeSection
enum Home {
    enum Section: CaseIterable {
        case promotion
        case category
        case movie
        case liveChannel
        case epg
        
        ///
        /// Optional:
        /// We receive titles from backend.
        /// There was not any requirements to create hardcoded namings.
        /// 
        
        var title: String {
            switch self {
            case .category:
                return "Категорії"
            case .movie:
                return "Новинки Київстар ТБ"
            case .liveChannel:
                return "Дитячі телеканали"
            case .epg:
                return "Пізнавальні"
            default:
                return ""
            }
        }
    }
    
    enum Item: Hashable {
        case promotion(Promotion)
        case category(Category)
        case movie(Asset)
        case liveChannel(Asset)
        case epg(Asset)
    }
}
