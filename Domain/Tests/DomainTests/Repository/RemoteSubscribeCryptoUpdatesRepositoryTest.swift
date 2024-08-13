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
        AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await (data, response) in stream {
                        // TODO: Do it on the next test case
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
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
    
    func test_subscribe_receiveError() async {
        let error = NSError(domain: "Any", code: 0)
        let injectedStream = AsyncThrowingStream<(Data, URLResponse), Error> { continuation in
            continuation.finish(throwing: error)
        }
        let client = SubscribeCryptoUpdatesHTTPClientStub(stream: injectedStream)
        let sut = RemoteSubscribeCryptoUpdatesRepository(client: client)
        var capturedError: Error?
        
        let stream = sut.subscribe(to: ["BTC", "ETH"])
        
        do {
            for try await _ in stream {
                XCTFail("Received a success, not an error")
            }
        } catch {
             capturedError = error
        }
        
        XCTAssertNotNil(capturedError)
    }
    
    // MARK: - Helper
    private func makeSUT() -> (sut: RemoteSubscribeCryptoUpdatesRepository, SubscribeCryptoUpdatesHTTPClientSpy) {
        let client = SubscribeCryptoUpdatesHTTPClientSpy()
        let sut = RemoteSubscribeCryptoUpdatesRepository(client: client)
        
        return (sut, client)
    }
    
    final class SubscribeCryptoUpdatesHTTPClientStub: SubscribeCryptoUpdatesHTTPClient {
        let stream: AsyncThrowingStream<(Data, URLResponse), Error>
        
        init(stream: AsyncThrowingStream<(Data, URLResponse), Error>) {
            self.stream = stream
        }
        
        func subscribe(to cryptos: [String]) -> AsyncThrowingStream<(Data, URLResponse), any Error> {
            stream
        }
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
