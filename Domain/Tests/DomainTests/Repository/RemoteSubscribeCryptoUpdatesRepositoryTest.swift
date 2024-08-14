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
                        continuation.yield(try decodeData(from: data))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private func decodeData(from data: Data) throws -> [CryptoModel] {
        do {
            let response = try JSONDecoder().decode(SubscribeResponse.self, from: data)
            return response.data
        } catch {
            throw error
        }
    }
}

struct SubscribeResponse: Decodable {
    let arg: SubscribedChannels
    let data: [CryptoModel]
}

struct SubscribedChannels: Decodable {
    let channel: String
    let instId: String
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
    
    func test_subscribe_receiveUpdates() async {
        let jsonData = try! JSONFileLoader.load(fileName: "WSTickerResponse")
        let (data, response) = (jsonData, URLResponse())
        var updates = [CryptoModel]()
        let injectedStream = AsyncThrowingStream<(Data, URLResponse), Error> { continuation in
            updates = try! decodeData(from: data)
            continuation.yield((data, response))
            continuation.finish()
        }
        let client = SubscribeCryptoUpdatesHTTPClientStub(stream: injectedStream)
        let sut = RemoteSubscribeCryptoUpdatesRepository(client: client)
        var capturedUpdates = [CryptoModel]()
        
        let stream = sut.subscribe(to: ["BTC", "ETH"])
        
        do {
            for try await models in stream {
                capturedUpdates = models
            }
        } catch {
            XCTFail("Received an error, not a success")
        }
        
        XCTAssertEqual(capturedUpdates, updates)
    }
    
    // MARK: - Helper
    private func decodeData(from data: Data) throws -> [CryptoModel] {
        do {
            let response = try JSONDecoder().decode(SubscribeResponse.self, from: data)
            return response.data
        } catch {
            throw error
        }
    }
    
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
