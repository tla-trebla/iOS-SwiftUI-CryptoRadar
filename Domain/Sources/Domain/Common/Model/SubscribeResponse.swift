//
//  SubscribeResponse.swift
//  
//
//  Created by Albert Pangestu on 14/08/24.
//

struct SubscribeResponse: Decodable {
    let arg: SubscribedChannels
    let data: [CryptoModel]
}

struct SubscribedChannels: Decodable {
    let channel: String
    let instId: String
}
