//
//  DIContainer.swift
//
//
//  Created by Vadim Marchenko on 09.04.2024.
//

import Foundation
import Core
import Domain
import Data

enum DIContainerError: Error {
    case missingDependency(String)
}

public protocol DIContainer: AnyObject {
    func resolve<Dependency>(type: Dependency.Type) -> Dependency
}

final class DIContainerImpl: DIContainer {

    // MARK: - Properties
    private var dependencies: [String: Any] = [:]
    private let logger: AppLogger = .diContainer
    
    public init() {
        logger.info("DIContainer initialized")
    }
    
    // MARK: Dependencies
    private lazy var templateRepository: TemplatesRepository = {
        let authentication = Authentication(barier: API.barrier)
        let networkService = NetworkServiceImpl(authentication: authentication)
        let repository = TemplatesRepositoryImpl(networkService: networkService)
        logger.info("TemplateService registered")
        return repository
    }()
    
    // MARK: - Public methods
    func resolve<Dependency>(type: Dependency.Type) -> Dependency {
        let typeKey = "\(type)"
        // Register dependency at first time
        if dependencies[typeKey] == nil {
            register(type: type)
        }
        guard let dependency = dependencies[typeKey] as? Dependency else {
            fatalError("Could not resolve dependency \(typeKey)")
        }
        logger.info("Dependency \(type) resolved")
        return dependency
    }

    // MARK: - Private methods
    private func register<Dependency>(type: Dependency.Type) {
        if type == TemplatesRepository.self {
            dependencies["\(type)"] = templateRepository
        }
    }
    
    deinit {
        logger.info("DIContainer deallocated")
    }
}


///
/// Overal:
/// + Approach with packages
/// + MVVM+C knowledge
/// + Structure of code
/// + Accuracy in strategy selections
/// + No memory leaks and UI lags
///
/// - Some missunderstanding with modern concurency
/// - Lack of documentation in some cases
/// - Not all requirements are met (slight inattention)
/// -- No back button in asset page
/// -- Not all content groups are displayed
/// -- If one request fails all other data will not be displayed or loaded
/// - Minor issues (described in comments)
///
/// I would recomend our HR team to proceed with you to the next stage - `tech interview`.
/// Please, contact `Yulia` directly in the comfort way to assign time for the next stage.
/// Thanks for your time.
///
