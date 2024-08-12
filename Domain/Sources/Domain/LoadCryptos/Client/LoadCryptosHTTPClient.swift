//
//  LoadCryptosHTTPClient.swift
//
//
//  Created by Albert Pangestu on 11/08/24.
//

import Foundation

protocol LoadCryptosHTTPClient {
    func load() async throws -> (Data, URLResponse)
}
