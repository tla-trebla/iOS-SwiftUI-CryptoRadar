//
//  RemoteSubscribeCryptoUpdatesRepository.swift
//
//
//  Created by Albert Pangestu on 14/08/24.
//

import Foundation

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
                    for try await (data, _) in stream {
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
