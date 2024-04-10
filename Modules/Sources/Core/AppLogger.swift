//
//  AppLogger.swift
//
//
//  Created by Vadim Marchenko on 09.04.2024.
//

import Foundation
import OSLog

public typealias AppLogger = Logger

extension Logger {

    enum LogCategory: String {
        case networkService
        case coordinator
        case sceneDelegate
        case diContainer
       
        func callAsFunction() -> String {
            self.rawValue
        }
    }

    private static var bundleIdentifier: String {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            fatalError("No bundle identifier was found")
        }
        return bundleIdentifier
    }

    public static let networkService = Logger.with(category: .networkService)
    public static let coordinator = Logger.with(category: .coordinator)
    public static let sceneDelegate = Logger.with(category: .sceneDelegate)
    public static let diContainer = Logger.with(category: .diContainer)
}

extension Logger {

    static func with(category: LogCategory) -> Logger {
        return Logger(subsystem: bundleIdentifier, category: category())
    }
}

