//
//  RemoteLoadCryptosRepository.swift
//
//
//  Created by Albert Pangestu on 11/08/24.
//

import Foundation

final class RemoteLoadCryptosRepository: LoadCryptosRepository {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() async throws -> [CryptoModel] {
        let (data, _) = try await client.load()
        return try decodeData(from: data)
    }
    
    private func decodeData(from data: Data) throws -> [CryptoModel] {
        do {
            let response = try JSONDecoder().decode(ApiResponse.self, from: data)
            return response.data
        } catch {
            throw error
        }
    }
}
