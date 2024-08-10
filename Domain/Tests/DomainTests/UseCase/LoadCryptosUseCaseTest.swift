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
    
    func load() async throws -> String {
        try await repository.load()
    }
}

protocol LoadCryptosRepository {
    func load() async throws -> String
}

final class LoadCryptosUseCaseTest: XCTestCase {

    func test_initialize_notRequesting() {
        let (_, repository) = makeSUT()
        
        XCTAssertEqual(repository.messages, [])
    }
    
    func test_load_shouldRequest() async {
        let (sut, repository) = makeSUT()
        
        _ = try? await sut.load()
        
        XCTAssertEqual(repository.messages, [.loaded])
    }
    
    func test_loadMore_requestMore() async {
        let (sut, repository) = makeSUT()
        
        _ = try? await sut.load()
        _ = try? await sut.load()
        
        XCTAssertEqual(repository.messages, [.loaded, .loaded])
    }
    
    func test_load_returnsError() async {
        let error = NSError(domain: "Any", code: 0)
        let repository = LoadCryptosRepositoryStub(result: .failure(error))
        let sut = LoadCryptosUseCase(repository: repository)
        var capturedError: Error?
        
        do {
            _ = try await sut.load()
            XCTFail("Expected an error, not a success")
        } catch {
            capturedError = error
        }
        
        XCTAssertNotNil(capturedError)
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: LoadCryptosUseCase, LoadCryptosRepositorySpy) {
        let repository = LoadCryptosRepositorySpy()
        let sut = LoadCryptosUseCase(repository: repository)
        
        return (sut, repository)
    }
    
    final class LoadCryptosRepositoryStub: LoadCryptosRepository {
        let result: Result<String, Error>
        
        init(result: Result<String, Error>) {
            self.result = result
        }
        
        func load() async throws -> String {
            try result.get()
        }
    }
    
    final class LoadCryptosRepositorySpy: LoadCryptosRepository {
        private(set) var messages: [Message] = []
        
        func load() async throws -> String {
            messages.append(.loaded)
            return ""
        }
        
        enum Message {
            case loaded
        }
    }
}
