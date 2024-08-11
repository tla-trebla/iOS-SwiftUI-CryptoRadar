//
//  RemoteLoadCryptosRepositoryTest.swift
//  
//
//  Created by Albert Pangestu on 11/08/24.
//

import XCTest
@testable import Domain

final class RemoteLoadCryptosRepository: LoadCryptosRepository {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() async throws -> [CryptoModel] {
        try await client.load()
    }
}

protocol HTTPClient {
    func load() async throws -> [CryptoModel]
}

final class RemoteLoadCryptosRepositoryTest: XCTestCase {

    func test_initialize_notRequesting() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestCount, 0)
    }
    
    func test_loadOnce_requestOnce() async {
        let (sut, client) = makeSUT()
        
        _ = try? await sut.load()
        
        XCTAssertEqual(client.requestCount, 1)
    }
    
    func test_loadMore_requestMore() async {
        let (sut, client) = makeSUT()
        
        _ = try? await sut.load()
        _ = try? await sut.load()
        
        XCTAssertEqual(client.requestCount, 2)
    }
    
    func test_load_returnError() async {
        let error = NSError(domain: "Any", code: 0)
        let client = HTTPClientStub(result: .failure(error))
        let sut = RemoteLoadCryptosRepository(client: client)
        var capturedError: Error?
        
        do {
            _ = try await sut.load()
            XCTFail("Gets a success, not an error")
        } catch {
            capturedError = error
        }
        
        XCTAssertNotNil(capturedError)
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: RemoteLoadCryptosRepository, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoadCryptosRepository(client: client)
        
        return (sut, client)
    }
    
    final class HTTPClientStub : HTTPClient {
        let result: Result<[CryptoModel], Error>
        
        init(result: Result<[CryptoModel], Error>) {
            self.result = result
        }
        
        func load() async throws -> [CryptoModel] {
            try result.get()
        }
    }
    
    final class HTTPClientSpy: HTTPClient {
        private(set) var requestCount: Int = 0
        
        func load() async throws -> [CryptoModel] {
            requestCount += 1
            return [CryptoModel]()
        }
    }
    
}
