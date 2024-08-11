//
//  SubscribeCryptoUpdatesUseCaseTest.swift
//  
//
//  Created by Albert Pangestu on 11/08/24.
//

import XCTest
@testable import Domain

final class SubscribeCryptoUpdatesUseCase {
    let repository: SubscribeCryptoUpdatesRepository
    
    init(repository: SubscribeCryptoUpdatesRepository) {
        self.repository = repository
    }
    
    func subscribe(to cryptos: [String]) async throws -> [CryptoModel] {
        try await repository.subscribe(to: cryptos)
    }
}

protocol SubscribeCryptoUpdatesRepository {
    func subscribe(to cryptos: [String]) async throws -> [CryptoModel]
}

final class SubscribeCryptoUpdatesUseCaseTest: XCTestCase {
    func test_initialize_notRequesting() {
        let repository = SubscribeCryptoUpdatesRepositorySpy()
        let sut = SubscribeCryptoUpdatesUseCase(repository: repository)
        
        XCTAssertEqual(repository.requestCount, 0)
    }
    
    func test_subscribeOnce_requestOnce() async {
        let repository = SubscribeCryptoUpdatesRepositorySpy()
        let sut = SubscribeCryptoUpdatesUseCase(repository: repository)
        
        _ = try? await sut.subscribe(to: ["BTC", "ETH"])
        
        XCTAssertEqual(repository.requestCount, 1)
    }
    
    func test_subscribeMore_requestMore() async {
        let repository = SubscribeCryptoUpdatesRepositorySpy()
        let sut = SubscribeCryptoUpdatesUseCase(repository: repository)
        
        _ = try? await sut.subscribe(to: ["BTC", "ETH"])
        _ = try? await sut.subscribe(to: ["BTC", "ETH"])
        
        XCTAssertEqual(repository.requestCount, 2)
    }
    
    // MARK: - Helper
    final class SubscribeCryptoUpdatesRepositorySpy: SubscribeCryptoUpdatesRepository {
        private(set) var requestCount: Int = 0
        
        func subscribe(to cryptos: [String]) async throws -> [CryptoModel] {
            requestCount += 1
            return [CryptoModel]()
        }
    }
}
