//
//  SubscribeCryptoUpdatesUseCase.swift
//
//
//  Created by Albert Pangestu on 12/08/24.
//

final class SubscribeCryptoUpdatesUseCase {
    let repository: SubscribeCryptoUpdatesRepository
    
    init(repository: SubscribeCryptoUpdatesRepository) {
        self.repository = repository
    }
    
    func subscribe(to cryptos: [String]) -> AsyncThrowingStream<[CryptoModel], Error> {
        let stream = repository.subscribe(to: cryptos)
        
        return stream
    }
}
