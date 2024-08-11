//
//  LoadCryptosUseCase.swift
//  
//
//  Created by Albert Pangestu on 11/08/24.
//

final class LoadCryptosUseCase {
    let repository: LoadCryptosRepository
    
    init(repository: LoadCryptosRepository) {
        self.repository = repository
    }
    
    func load() async throws -> [CryptoModel] {
        try await repository.load()
    }
}
