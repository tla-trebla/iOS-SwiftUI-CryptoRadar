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
    
    init(loadUseCase: LoadCryptosUseCaseProtocol) {
        self.loadUseCase = loadUseCase
    }
}

protocol LoadCryptosUseCaseProtocol {
    func load() async throws -> [CryptoModel]
}

final class CryptosListViewModelTest: XCTestCase {

    func test_init_notLoading() {
        let loadUseCase = LoadCryptosUseCaseSpy()
        let sut = CryptosListViewModel(loadUseCase: loadUseCase)
        
        XCTAssertEqual(loadUseCase.requestCount, 0)
    }
    
    // MARK: - Helper
    final class LoadCryptosUseCaseSpy: LoadCryptosUseCaseProtocol {
        let requestCount: Int = 0
        
        func load() async throws -> [CryptoModel] {
            [CryptoModel]()
        }
    }
}
