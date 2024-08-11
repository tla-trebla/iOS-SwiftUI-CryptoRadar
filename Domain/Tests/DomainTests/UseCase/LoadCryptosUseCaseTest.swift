//
//  LoadCryptosUseCaseTest.swift
//  
//
//  Created by Albert Pangestu on 10/08/24.
//

import XCTest
@testable import Domain

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
        let sut = makeSUT(result: .failure(error))
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
        let cryptos = [anyCryptoModel(), anyCryptoModel()]
        let sut = makeSUT(result: .success(cryptos))
        var capturedCryptos: [CryptoModel] = []
        
        do {
            capturedCryptos = try await sut.load()
        } catch {
            XCTFail("Expected a success, not an error")
        }
        
        XCTAssertEqual(capturedCryptos, cryptos)
    }
    
    // MARK: - Helpers
    private func makeSUT(result: Result<[CryptoModel], Error>) -> LoadCryptosUseCase {
        let repository = LoadCryptosRepositoryStub(result: result)
        let sut = LoadCryptosUseCase(repository: repository)
        
        return sut
    }
    
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
            return [CryptoModel]()
        }
        
        enum Message {
            case loaded
        }
    }
    
    private func anyCryptoModel() -> CryptoModel {
        CryptoModel(instType: "SWAP", instId: "LTC-USD-SWAP", last: "9999.99", lastSz: "1", askPx: "9999.99", askSz: "11", bidPx: "8888.88", bidSz: "5", open24h: "9000", high24h: "10000", low24h: "8888.88", volCcy24h: "2222", vol24h: "2222", sodUtc0: "0.1", sodUtc8: "0.1", ts: "1597026383085")
    }
}
