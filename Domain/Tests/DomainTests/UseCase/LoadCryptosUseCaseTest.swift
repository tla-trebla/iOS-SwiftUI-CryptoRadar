//
//  LoadCryptosUseCaseTest.swift
//  
//
//  Created by Albert Pangestu on 10/08/24.
//

import XCTest

final class LoadCryptosUseCase {
    let repository: LoadCryptosRepository
    
    init(repository: LoadCryptosRepository) {
        self.repository = repository
    }
}

protocol LoadCryptosRepository {}

final class LoadCryptosUseCaseTest: XCTestCase {

    func test_initialize_notRequesting() {
        let repository = LoadCryptosRepositorySpy()
        let sut = LoadCryptosUseCase(repository: repository)
        
        XCTAssertEqual(repository.requestCount, 0)
    }
    
    // MARK: - Helpers
    final class LoadCryptosRepositorySpy: LoadCryptosRepository {
        let requestCount: Int = 0
    }
}
