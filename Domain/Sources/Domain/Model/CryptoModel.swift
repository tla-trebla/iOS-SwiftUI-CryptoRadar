//
//  CryptoModel.swift
//
//
//  Created by Albert Pangestu on 11/08/24.
//

struct CryptoModel: Codable, Equatable {
    let instType: String
    let instID: String
    let last: String
    let lastSz: String
    let askPx: String
    let askSz: String
    let bidPx: String
    let bidSz: String
    let open24H: String
    let high24H: String
    let low24H: String
    let volCcy24H: String
    let vol24H: String
    let sodUtc0: String
    let sodUtc8: String
    let ts: String
}
