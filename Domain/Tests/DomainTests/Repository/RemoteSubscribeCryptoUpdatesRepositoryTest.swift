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
        let stream = client.subscribe(to: cryptos)
        return translateData(from: stream)
    }
    
    private func translateData(from stream: AsyncThrowingStream<(Data, URLResponse), Error>) -> AsyncThrowingStream<[CryptoModel], Error> {
        AsyncThrowingStream { _ in }
    }
}

protocol SubscribeCryptoUpdatesHTTPClient {
    func subscribe(to cryptos: [String]) -> AsyncThrowingStream<(Data, URLResponse), Error>
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
    
    func test_subscribeMore_requestMore() {
        let client = SubscribeCryptoUpdatesHTTPClientSpy()
        let sut = RemoteSubscribeCryptoUpdatesRepository(client: client)
        
        _ = sut.subscribe(to: ["BTC", "ETH"])
        _ = sut.subscribe(to: ["BTC", "ETH"])
        
        XCTAssertEqual(client.requestCount, 2)
    }
    
    // MARK: - Helper
    final class SubscribeCryptoUpdatesHTTPClientSpy: SubscribeCryptoUpdatesHTTPClient {
        private(set) var requestCount: Int = 0
        
        func subscribe(to cryptos: [String]) -> AsyncThrowingStream<(Data, URLResponse), Error> {
            requestCount += 1
            return AsyncThrowingStream { _ in }
        }
    }
}
