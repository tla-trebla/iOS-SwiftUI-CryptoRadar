//
//  SubscribeCryptoUpdatesRepository.swift
//
//
//  Created by Albert Pangestu on 12/08/24.
//

protocol SubscribeCryptoUpdatesRepository {
    func subscribe(to cryptos: [String]) -> AsyncThrowingStream<[CryptoModel], Error>
}
