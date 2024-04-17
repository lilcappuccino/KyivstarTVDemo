//
//  AssetDetailsAPI.swift
//
//
//  Created by Vadim Marchenko on 09.04.2024.
//

import Foundation

// MARK: - AssetDetailsAPI

///
/// Optional:
/// If we want only decoding of the JSON data, then we have to conform to the Decodable protocol only.
/// The Codable protocol will be required if we need to support decoding and encoding both.
///

public struct AssetDetailsAPI: Codable {
    public let id, name: String
    public let image: String
    public let company: String
    public let similar: [SimilarAssetAPI]
    public let duration, progress: Int
    public let purchased: Bool
    public let updatedAt, description, releaseDate: String
}

// MARK: - SimilarAssetAPI
public struct SimilarAssetAPI: Codable {
    public let id, name: String
    public let image: String
    public let company: String
    public let progress: Int
    public let purchased: Bool
    public let updatedAt, releaseDate: String
}

