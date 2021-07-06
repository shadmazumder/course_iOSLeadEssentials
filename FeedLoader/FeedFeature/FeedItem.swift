//
//  FeedItem.swift
//  FeedLoader
//
//  Created by SHAD MAZUMDER on 6/9/21.
//

import Foundation

public struct FeedItem: Equatable{
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageUrl: URL
}

extension FeedItem: Decodable {
     private enum CodingKeys: String, CodingKey {
         case id
         case description
         case location
         case imageUrl = "image"
     }
 }
