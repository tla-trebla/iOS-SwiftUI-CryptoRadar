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
    
    func load() async throws -> [CryptoModel] {
        try await repository.load()
    }
}

protocol LoadCryptosRepository {
    func load() async throws -> [CryptoModel]
}

struct CryptoModel: Codable, Equatable {
    let instType: String
    let instID: String
    let last: String
    let lastSz: String
    let askPx: String
    let askSz: String
    let bidPx: String
    let bidSz: String
    let open24H: String
    let high24H: String
    let low24H: String
    let volCcy24H: String
    let vol24H: String
    let sodUtc0: String
    let sodUtc8: String
    let ts: String
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
    
    func test_load_returnError() async throws {
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
    
    func test_load_returnCryptos() async throws {
        let cryptos = [CryptoModel(instType: "SWAP", instID: "LTC-USD-SWAP", last: "9999.99", lastSz: "1", askPx: "9999.99", askSz: "11", bidPx: "8888.88", bidSz: "5", open24H: "9000", high24H: "10000", low24H: "8888.88", volCcy24H: "2222", vol24H: "2222", sodUtc0: "0.1", sodUtc8: "0.1", ts: "1597026383085"),
                       CryptoModel(instType: "SWAP", instID: "LTC-USD-SWAP", last: "9999.99", lastSz: "1", askPx: "9999.99", askSz: "11", bidPx: "8888.88", bidSz: "5", open24H: "9000", high24H: "10000", low24H: "8888.88", volCcy24H: "2222", vol24H: "2222", sodUtc0: "0.1", sodUtc8: "0.1", ts: "1597026383085")]
        let repository = LoadCryptosRepositoryStub(result: .success(cryptos))
        let sut = LoadCryptosUseCase(repository: repository)
        var capturedCryptos: [CryptoModel] = []
        
        do {
            capturedCryptos = try await sut.load()
        } catch {
            XCTFail("Expected a success, not an error")
        }
        
        XCTAssertEqual(capturedCryptos, cryptos)
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: LoadCryptosUseCase, LoadCryptosRepositorySpy) {
        let repository = LoadCryptosRepositorySpy()
        let sut = LoadCryptosUseCase(repository: repository)
        
        return (sut, repository)
    }
    
    final class LoadCryptosRepositoryStub: LoadCryptosRepository {
        let result: Result<[CryptoModel], Error>
        
        init(result: Result<[CryptoModel], Error>) {
            self.result = result
        }
        
        func load() async throws -> [CryptoModel] {
            try result.get()
        }
    }
    
    final class LoadCryptosRepositorySpy: LoadCryptosRepository {
        private(set) var messages: [Message] = []
        
        func load() async throws -> [CryptoModel] {
            messages.append(.loaded)
            return [CryptoModel(instType: "SWAP", instID: "LTC-USD-SWAP", last: "9999.99", lastSz: "1", askPx: "9999.99", askSz: "11", bidPx: "8888.88", bidSz: "5", open24H: "9000", high24H: "10000", low24H: "8888.88", volCcy24H: "2222", vol24H: "2222", sodUtc0: "0.1", sodUtc8: "0.1", ts: "1597026383085")]
        }
        
        enum Message {
            case loaded
        }
    }
}
