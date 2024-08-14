//
//  SubscribeCryptoUpdatesHTTPClient.swift
//  
//
//  Created by Albert Pangestu on 14/08/24.
//

import Foundation

protocol SubscribeCryptoUpdatesHTTPClient {
    func subscribe(to cryptos: [String]) -> AsyncThrowingStream<(Data, URLResponse), Error>
}
