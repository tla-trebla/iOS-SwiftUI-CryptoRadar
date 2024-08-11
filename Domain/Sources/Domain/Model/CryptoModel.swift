//
//  CryptoModel.swift
//
//
//  Created by Albert Pangestu on 11/08/24.
//

struct CryptoModel: Codable, Equatable {
    let instType: String
    let instId: String
    let last: String
    let lastSz: String
    let askPx: String
    let askSz: String
    let bidPx: String
    let bidSz: String
    let open24h: String
    let high24h: String
    let low24h: String
    let volCcy24h: String
    let vol24h: String
    let sodUtc0: String
    let sodUtc8: String
    let ts: String
}
