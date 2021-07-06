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
    public let localtion: String?
    public let imageUrl: URL
}
