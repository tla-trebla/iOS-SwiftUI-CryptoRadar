//
//  JSONFileLoader.swift
//  
//
//  Created by Albert Pangestu on 13/08/24.
//

import Foundation

enum JSONFileLoader {
    static func load(fileName: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: fileName, withExtension: "json") else {
            throw JSONFileLoaderError.FileNotFound
        }
        
        do {
            return try Data(contentsOf: url)
        } catch {
            throw JSONFileLoaderError.CannotDecodeFromURL
        }
    }
    
    enum JSONFileLoaderError: Swift.Error {
        case CannotDecodeFromURL
        case FileNotFound
    }
}
