//
//  ContentGroupsAPI.swift
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


// MARK: - ContentGroupsAPI
public struct ContentGroupsAPI: Codable {
    public let id, name: String
    public let type: [String]
    public let assets: [AssetAPI]
    public let hidden: Bool
    public let sortIndex: Int
    public let canBeDeleted: Bool
}

// MARK: - AssetAPI
public struct AssetAPI: Codable {
    public let id, name: String
    public let image: String
    public let company: String
    public let progress: Int
    public let purchased: Bool
    public let sortIndex: Int
    public let updatedAt, releaseDate: String
}
