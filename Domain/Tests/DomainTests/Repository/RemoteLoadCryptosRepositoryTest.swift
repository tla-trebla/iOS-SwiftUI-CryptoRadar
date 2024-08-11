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
        let client = HTTPClientSpy()
        let sut = RemoteLoadCryptosRepository(client: client)
        
        XCTAssertEqual(client.requestCount, 0)
    }
    
    func test_loadOnce_requestOnce() async {
        let client = HTTPClientSpy()
        let sut = RemoteLoadCryptosRepository(client: client)
        
        _ = try? await sut.load()
        
        XCTAssertEqual(client.requestCount, 1)
    }
    
    func test_loadMore_requestMore() async {
        let client = HTTPClientSpy()
        let sut = RemoteLoadCryptosRepository(client: client)
        
        _ = try? await sut.load()
        _ = try? await sut.load()
        
        XCTAssertEqual(client.requestCount, 2)
    }
    
    // MARK: - Helpers
    final class HTTPClientSpy: HTTPClient {
        private(set) var requestCount: Int = 0
        
        func load() async throws -> [CryptoModel] {
            requestCount += 1
            return [CryptoModel]()
        }
    }
    
}
