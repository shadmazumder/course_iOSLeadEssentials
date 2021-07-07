//
//  FeedItemMapper.swift
//  FeedLoader
//
//  Created by SHAD MAZUMDER on 7/7/21.
//

import Foundation

internal class FeedItemMapper{
    private struct Root: Decodable{
        let items: [Item]
    }
    
    private struct Item: Decodable{
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem{
            return FeedItem(id: id, description: description, location: location, imageUrl: image)
        }
    }
    
    static var ok_200: Int { return 200 }
    
    static func map(response: HTTPURLResponse, data: Data) throws -> [FeedItem]{
        guard response.statusCode == ok_200 else{ throw RemoteFeedLoader.Error.invalidData }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map({ $0.item })
    }
}
