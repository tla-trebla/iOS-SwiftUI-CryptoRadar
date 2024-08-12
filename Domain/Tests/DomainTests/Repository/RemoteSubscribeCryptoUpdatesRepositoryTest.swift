//
//  RemoteSubscribeCryptoUpdatesRepositoryTest.swift
//  
//
//  Created by Albert Pangestu on 12/08/24.
//

import XCTest
@testable import Domain

final class RemoteSubscribeCryptoUpdatesRepository: SubscribeCryptoUpdatesRepository {
    let client: SubscribeCryptoUpdatesHTTPClient
    
    init(client: SubscribeCryptoUpdatesHTTPClient) {
        self.client = client
    }
    
    func subscribe(to cryptos: [String]) -> AsyncThrowingStream<[CryptoModel], any Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    _ = try await client.subscribe(to: cryptos)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

protocol SubscribeCryptoUpdatesHTTPClient {
    func subscribe(to cryptos: [String]) async throws -> (Data, URLResponse)
}

final class RemoteSubscribeCryptoUpdatesRepositoryTest: XCTestCase {

    func test_initialize_notRequesting() {
        let client = SubscribeCryptoUpdatesHTTPClientSpy()
        let sut = RemoteSubscribeCryptoUpdatesRepository(client: client)
        
        XCTAssertEqual(client.requestCount, 0)
    }
    
    func test_subscribeOnce_requestOnce() {
        let client = SubscribeCryptoUpdatesHTTPClientSpy()
        let sut = RemoteSubscribeCryptoUpdatesRepository(client: client)
        
        _ = sut.subscribe(to: ["BTC", "ETH"])
        
        XCTAssertEqual(client.requestCount, 1)
    }
    
    // MARK: - Helper
    final class SubscribeCryptoUpdatesHTTPClientSpy: SubscribeCryptoUpdatesHTTPClient {
        private(set) var requestCount: Int = 0
        
        func subscribe(to cryptos: [String]) async throws -> (Data, URLResponse) {
            requestCount = 1
            return (Data(), URLResponse())
        }
    }
}
