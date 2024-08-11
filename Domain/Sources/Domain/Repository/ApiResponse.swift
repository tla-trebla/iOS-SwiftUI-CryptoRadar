//
//  ApiResponse.swift
//  
//
//  Created by Albert Pangestu on 11/08/24.
//

struct ApiResponse: Decodable {
    let code: String
    let msg: String
    let data: [CryptoModel]
}
