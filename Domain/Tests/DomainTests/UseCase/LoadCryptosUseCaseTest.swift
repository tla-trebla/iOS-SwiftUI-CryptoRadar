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
    
    func load() {
        repository.load()
    }
}

protocol LoadCryptosRepository {
    func load()
}

final class LoadCryptosUseCaseTest: XCTestCase {

    func test_initialize_notRequesting() {
        let (_, repository) = makeSUT()
        
        XCTAssertEqual(repository.messages, [])
    }
    
    func test_load_shouldRequest() {
        let (sut, repository) = makeSUT()
        
        sut.load()
        
        XCTAssertEqual(repository.messages, [.loaded])
    }
    
    func test_loadMore_requestMore() {
        let (sut, repository) = makeSUT()
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(repository.messages, [.loaded, .loaded])
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: LoadCryptosUseCase, LoadCryptosRepositorySpy) {
        let repository = LoadCryptosRepositorySpy()
        let sut = LoadCryptosUseCase(repository: repository)
        
        return (sut, repository)
    }
    
    final class LoadCryptosRepositorySpy: LoadCryptosRepository {
        private(set) var messages: [Message] = []
        
        func load() {
            messages.append(.loaded)
        }
        
        enum Message {
            case loaded
        }
    }
}
