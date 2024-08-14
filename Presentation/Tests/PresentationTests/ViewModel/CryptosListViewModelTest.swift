//
//  CryptosListViewModelTest.swift
//  
//
//  Created by Albert Pangestu on 14/08/24.
//

import XCTest
import Domain

final class CryptosListViewModel: ObservableObject {
    let loadUseCase: LoadCryptosUseCaseProtocol
    let subscribeUseCase: SubscribeCryptoUpdatesUseCaseProtocol
    
    init(loadUseCase: LoadCryptosUseCaseProtocol, subscribeUseCase: SubscribeCryptoUpdatesUseCaseProtocol) {
        self.loadUseCase = loadUseCase
        self.subscribeUseCase = subscribeUseCase
    }
}

protocol LoadCryptosUseCaseProtocol {
    func load() async throws -> [CryptoModel]
}

protocol SubscribeCryptoUpdatesUseCaseProtocol {
    func subscribe(to cryptos: [String]) -> AsyncThrowingStream<[CryptoModel], Error>
}

final class CryptosListViewModelTest: XCTestCase {

    func test_init_notLoading() {
        let loadUseCase = LoadCryptosUseCaseSpy()
        let subscribeUseCase = SubscribeCryptoUpdatesUseCaseSpy()
        let sut = CryptosListViewModel(loadUseCase: loadUseCase,
                                       subscribeUseCase: subscribeUseCase)
        
        XCTAssertEqual(loadUseCase.requestCount, 0)
    }
    
    func test_init_notListening() {
        let loadUseCase = LoadCryptosUseCaseSpy()
        let subscribeUseCase = SubscribeCryptoUpdatesUseCaseSpy()
        let sut = CryptosListViewModel(loadUseCase: loadUseCase,
                                       subscribeUseCase: subscribeUseCase)
        
        XCTAssertEqual(subscribeUseCase.subscribeCount, 0)
    }
    
    // MARK: - Helper
    final class LoadCryptosUseCaseSpy: LoadCryptosUseCaseProtocol {
        let requestCount: Int = 0
        
        func load() async throws -> [CryptoModel] {
            [CryptoModel]()
        }
    }
    
    final class SubscribeCryptoUpdatesUseCaseSpy: SubscribeCryptoUpdatesUseCaseProtocol {
        let subscribeCount: Int = 0
        
        func subscribe(to cryptos: [String]) -> AsyncThrowingStream<[CryptoModel], any Error> {
            AsyncThrowingStream<[CryptoModel], Error> { _ in }
        }
    }
}
