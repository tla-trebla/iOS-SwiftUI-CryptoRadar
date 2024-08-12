//
//  LoadCryptosRepository.swift
//
//
//  Created by Albert Pangestu on 11/08/24.
//

protocol LoadCryptosRepository {
    func load() async throws -> [CryptoModel]
}
