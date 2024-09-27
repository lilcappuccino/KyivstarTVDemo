//
//  NetworkService.swift
//
//
//  Created by Vadim Marchenko on 09.04.2024.
//

import Foundation
import Core

// MARK: - NetworkService
public protocol NetworkService: Any {
    func load<T: Decodable>(_ request: RequestWithResponse<T>) async throws -> T
}

// MARK: - NetworkServiceImpl
public final class NetworkServiceImpl: NetworkService {
    
    // MARK: - Properties
    private let logger = AppLogger.networkService
    private var authentication: Authentication
    
    // MARK: - Init
    public init(authentication: Authentication) {
        self.authentication = authentication
    }
    
    // MARK: - Public methods
    
    /**
     Optional:
        Service is quite good and usable, but not flexible and difficult to scale.
        Not a best practise of using throw here.
        When we want to cast throwed Error to our specific error - code becomes a boiler plate.
    
        do {
            try request.fetch(...params)
        } catch SomeError.ValidationError.contentGroupIsEmpty {

        } catch SomeError.ValidationError.promoAreaEmpty(let promoLength) where promoLength == 1 {

        } catch is SomeError.ValidationError {
            // All `SomeError.ValidationError` types except for the earlier catch `contentGroupIsEmpty` and `promoAreaEmpty` error.
            // switch case comes in
        } catch {
            // All other errors, alamofire/URLSession and iOS networking
        }
    */
    
    /**
     In swift 6 we will have great possibility, check it out → https://github.com/apple/swift-evolution/blob/main/proposals/0413-typed-throws.md
     And, what about if server will return us status - 200 OK and this:
    
         {
             "error": "No promotions for this user",
             "code": 3745,
             "rayId": "some_hash_here"
         }
     */
    
    public func load<T: Decodable>(_ request: RequestWithResponse<T>) async throws -> T {
        let urlRequest = try await generateURLRequest(from: request)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              let statusCode = HTTPStatusCode(rawValue: httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        switch statusCode {
        case .ok, .created, .accepted:
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                let responseString = String(decoding: data, as: UTF8.self)
                logger.info("Success \(request.endpoint.path): \(responseString)")
                return decodedObject
            } catch let error {
                logger.error("\((request.endpoint.path)): \(error)")
                throw NetworkError.jsonDecodingError(error: error)
            }
        case .unauthorized:
            logger.error("\(request.endpoint.path): unauthorized")
            throw NetworkError.unauthorized
        case .paymentRequired:
            logger.error("\(request.endpoint.path): paymentRequired")
            throw NetworkError.paymentRequired
        case .badRequest:
            logger.error("\(request.endpoint.path): \(statusCode)")
            throw NetworkError.dataLoadingError(statusCode.rawValue)
        default:
            if request.attempt <= request.repeatCount {
                var repeatedRequest = request
                repeatedRequest.repeatAttempt()
                logger.info("Repeat request: \(repeatedRequest.endpoint.path) attempt \(repeatedRequest.attempt)")
                return try await load(repeatedRequest)
            }
            logger.error("\(request.endpoint.path): \(statusCode)")
            throw NetworkError.unknown
        }
    }
    
    // MARK: - Private methods
    private func generateURLRequest(from request: Request) async throws -> URLRequest {
        let url = generateURL(endpoint: request.endpoint)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.endpoint.method.rawValue
        urlRequest = await addHeader(for: urlRequest)
        return urlRequest
    }
    
    private func generateURL(endpoint: Endpoint) -> URL {
        var url = API.baseURL
        url.appendPathComponent(endpoint.path)
        return url
    }
    
    private func addHeader(for request: URLRequest) async -> URLRequest {
        var request = request
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Why await here?  
        let barier = await authentication.barier
        request.addValue( "Bearer \(barier)", forHTTPHeaderField: "Authorization")
        return request
    }
}
