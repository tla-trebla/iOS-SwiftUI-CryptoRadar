//
//  RemoteLoadCryptosRepositoryTest.swift
//  
//
//  Created by Albert Pangestu on 11/08/24.
//

import XCTest
@testable import Domain

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
    
    func test_load_receiveCryptos() async throws {
        let jsonData = try! JSONFileLoader.load(fileName: "GetTickerResponse")
        let (data, response) = (jsonData, URLResponse())
        let decodedResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
        let decodedData = decodedResponse.data
        let client = HTTPClientStub(result: .success((data, response)))
        let sut = RemoteLoadCryptosRepository(client: client)
        var capturedCryptos: [CryptoModel] = []
        
        do {
            capturedCryptos = try await sut.load()
        } catch {
            XCTFail("Gets an error, not a success")
        }
        
        XCTAssertEqual(capturedCryptos, decodedData)
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: RemoteLoadCryptosRepository, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoadCryptosRepository(client: client)
        
        return (sut, client)
    }
    
    final class HTTPClientStub : HTTPClient {
        let result: Result<(Data, URLResponse), Error>
        
        init(result: Result<(Data, URLResponse), Error>) {
            self.result = result
        }
        
        func load() async throws -> (Data, URLResponse) {
            try result.get()
        }
    }
    
    final class HTTPClientSpy: HTTPClient {
        private(set) var requestCount: Int = 0
        
        func load() async throws -> (Data, URLResponse) {
            requestCount += 1
            return (Data(), URLResponse())
        }
    }
    
    private enum JSONFileLoader {
        static func load(fileName: String) throws -> Data {
            guard let url = Bundle.module.url(forResource: fileName, withExtension: "json") else {
                throw JSONFileLoaderError.FileNotFound
            }
            
            do {
                return try Data(contentsOf: url)
            } catch {
                throw JSONFileLoaderError.CannotDecodeFromURL
            }
        }
        
        enum JSONFileLoaderError: Swift.Error {
            case CannotDecodeFromURL
            case FileNotFound
        }
    }
}
