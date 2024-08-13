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
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.messages, [])
    }
    
    func test_subscribeOnce_requestOnce() {
        let (sut, client) = makeSUT()
        
        _ = sut.subscribe(to: ["BTC", "ETH"])
        
        XCTAssertEqual(client.messages, [.subscribe])
    }
    
    func test_subscribeMore_requestMore() {
        let (sut, client) = makeSUT()
        
        _ = sut.subscribe(to: ["BTC", "ETH"])
        _ = sut.subscribe(to: ["BTC", "ETH"])
        
        XCTAssertEqual(client.messages, [.subscribe, .subscribe])
    }
    
    // MARK: - Helper
    private func makeSUT() -> (sut: RemoteSubscribeCryptoUpdatesRepository, SubscribeCryptoUpdatesHTTPClientSpy) {
        let client = SubscribeCryptoUpdatesHTTPClientSpy()
        let sut = RemoteSubscribeCryptoUpdatesRepository(client: client)
        
        return (sut, client)
    }
    
    final class SubscribeCryptoUpdatesHTTPClientSpy: SubscribeCryptoUpdatesHTTPClient {
        private(set) var messages: [Message] = []
        
        func subscribe(to cryptos: [String]) -> AsyncThrowingStream<(Data, URLResponse), Error> {
            messages.append(.subscribe)
            return AsyncThrowingStream { _ in }
        }
        
        enum Message {
            case subscribe
        }
    }
}
