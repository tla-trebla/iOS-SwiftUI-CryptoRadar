//
//  SubscribeCryptoUpdatesUseCaseTest.swift
//  
//
//  Created by Albert Pangestu on 11/08/24.
//

import XCTest
@testable import Domain

final class SubscribeCryptoUpdatesUseCaseTest: XCTestCase {
    func test_initialize_notRequesting() {
        let (_, repository) = makeSUT()
        
        XCTAssertEqual(repository.messages, [])
    }
    
    func test_subscribeOnce_requestOnce() {
        let (sut, repository) = makeSUT()
        
        _ = sut.subscribe(to: ["BTC", "ETH"])
        
        XCTAssertEqual(repository.messages, [.subscribe])
    }
    
    func test_subscribeMore_requestMore() {
        let (sut, repository) = makeSUT()
        
        _ = sut.subscribe(to: ["BTC", "ETH"])
        _ = sut.subscribe(to: ["BTC", "ETH"])
        
        XCTAssertEqual(repository.messages, [.subscribe, .subscribe])
    }
    
    func test_subscribe_getsAnError() async {
        let error = NSError(domain: "Any", code: 0)
        let repository = SubscribeCryptoUpdatesRepositoryStub(result: .failure(error))
        let sut = SubscribeCryptoUpdatesUseCase(repository: repository)
        var capturedError: Error?
        
        let stream = sut.subscribe(to: ["BTC", "ETH"])
        
        do {
            for try await _ in stream {
                XCTFail("Gets a success, not an error")
            }
        } catch {
            capturedError = error
        }
        
        XCTAssertNotNil(capturedError)
    }
    
    func test_subscribe_getsTheUpdate() async {
        let cryptos: [CryptoModel] = [anyCryptoModel(), anyCryptoModel()]
        let repository = SubscribeCryptoUpdatesRepositoryStub(result: .success(cryptos))
        let sut = SubscribeCryptoUpdatesUseCase(repository: repository)
        var capturedCryptos: [CryptoModel] = []
        
        let stream = sut.subscribe(to: ["BTC", "ETH"])
        
        do {
            for try await models in stream {
                capturedCryptos = models
            }
        } catch {
            XCTFail("Gets an error, not a success")
        }
        
        XCTAssertEqual(capturedCryptos, cryptos)
    }
    
    // MARK: - Helper
    private func makeSUT() -> (sut: SubscribeCryptoUpdatesUseCase, SubscribeCryptoUpdatesRepositorySpy) {
        let repository = SubscribeCryptoUpdatesRepositorySpy()
        let sut = SubscribeCryptoUpdatesUseCase(repository: repository)
        
        return (sut, repository)
    }
    
    final class SubscribeCryptoUpdatesRepositoryStub: SubscribeCryptoUpdatesRepository {
        let result: Result<[CryptoModel], Error>
        
        init(result: Result<[CryptoModel], Error>) {
            self.result = result
        }
        
        func subscribe(to cryptos: [String]) -> AsyncThrowingStream<[CryptoModel], any Error> {
            AsyncThrowingStream { continuation in
                switch result {
                case .success(let models):
                    continuation.yield(models)
                    continuation.finish()
                case .failure(let failure):
                    continuation.finish(throwing: failure)
                }
            }
        }
    }
    
    final class SubscribeCryptoUpdatesRepositorySpy: SubscribeCryptoUpdatesRepository {
        private(set) var messages: [Message] = []
        
        func subscribe(to cryptos: [String]) -> AsyncThrowingStream<[CryptoModel], Error> {
            messages.append(.subscribe)
            return AsyncThrowingStream { _ in }
        }
        
        enum Message {
            case subscribe
        }
    }
}
