//
//  PromotionsAPI.swift
//
//
//  Created by Vadim Marchenko on 09.04.2024.
//

import Foundation

///
/// Optional:
/// If we want only decoding of the JSON data, then we have to conform to the Decodable protocol only.
/// The Codable protocol will be required if we need to support decoding and encoding both.
///


// MARK: - PromotionsAPI
public struct PromotionsAPI: Codable {
    public let id, name: String
    public let promotions: [PromotionAPI]
}

// MARK: - Promotion
public struct PromotionAPI: Codable {
    public let id, name: String
    public let image: String
    public let company, updatedAt, releaseDate: String
}
