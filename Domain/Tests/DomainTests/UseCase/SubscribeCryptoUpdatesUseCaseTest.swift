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
        
        XCTAssertEqual(repository.messages, [])
    }
    
    func test_subscribeOnce_requestOnce() async {
        let repository = SubscribeCryptoUpdatesRepositorySpy()
        let sut = SubscribeCryptoUpdatesUseCase(repository: repository)
        
        _ = try? await sut.subscribe(to: ["BTC", "ETH"])
        
        XCTAssertEqual(repository.messages, [.subscribe])
    }
    
    func test_subscribeMore_requestMore() async {
        let repository = SubscribeCryptoUpdatesRepositorySpy()
        let sut = SubscribeCryptoUpdatesUseCase(repository: repository)
        
        _ = try? await sut.subscribe(to: ["BTC", "ETH"])
        _ = try? await sut.subscribe(to: ["BTC", "ETH"])
        
        XCTAssertEqual(repository.messages, [.subscribe, .subscribe])
    }
    
    // MARK: - Helper
    final class SubscribeCryptoUpdatesRepositorySpy: SubscribeCryptoUpdatesRepository {
        private(set) var messages: [Message] = []
        
        func subscribe(to cryptos: [String]) async throws -> [CryptoModel] {
            messages.append(.subscribe)
            return [CryptoModel]()
        }
        
        enum Message {
            case subscribe
        }
    }
}
