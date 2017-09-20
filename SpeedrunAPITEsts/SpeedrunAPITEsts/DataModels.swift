//
//  DataModels.swift
//  SpeedrunAPITEsts
//
//  Created by Patrick O'Brien on 9/9/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import Foundation



struct GamesResponse : Codable {
    var data: [Game]
    var pagination: PaginationData?
}

struct Game : Codable {
    var id: String
    var names: Names
    var categories: CategoriesResponse?
    var releaseDate: String
    var assets: GameAssets
    var platforms: PlatformsResponse?
    var variables: VariablesResponse?
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case names = "names"
        case categories = "categories"
        case releaseDate = "release-date"
        case assets = "assets"
        case platforms = "platforms"
        case variables = "variables"
    }
}

struct GameAssets : Codable {
    var logo: GameImageData
    var coverSmall: GameImageData
    var coverMedium: GameImageData
    var coverLarge: GameImageData
    var icon: GameImageData
    var trophy1st: GameImageData
    var trophy2nd: GameImageData
    var trophy3rd: GameImageData
    
    enum CodingKeys: String, CodingKey {
        case logo = "logo"
        case coverSmall = "cover-small"
        case coverMedium = "cover-medium"
        case coverLarge = "cover-large"
        case icon = "icon"
        case trophy1st = "trophy-1st"
        case trophy2nd = "trophy-2nd"
        case trophy3rd = "trophy-3rd"
    }
}

struct GameImageData : Codable {
    var uri: String
    var height: Int
    var width: Int
}

struct Names : Codable {
    var international: String
    var japanese: String?
    var twitch: String?
}

struct CategoriesResponse : Codable {
    var data: [Category]
}

struct Category : Codable {
    var id: String
    var name: String
    var rules: String?
    var variables: VariablesResponse?
}

struct PlatformsResponse : Codable {
    var data: [Platforms]
}

struct Platforms : Codable {
    var id: String
    var name: String
}

struct VariablesResponse : Codable {
    var data: [Variable]
}

struct Variable : Codable {
    var id: String
    var name: String
    var values: VariablesValues
}

struct Choices : Codable {
    var label: String
    var rules: String?
}

struct VariablesValues : Codable {
    var values : [String: Choices]
}


struct PaginationData : Codable {
    var offset: Int
    var size: Int
    var max: Int
}





struct LeaderboardsResponse : Codable {
    var data : Leaderboards
}

struct Leaderboards : Codable {
    var runs: [RunPosition]
    var players: PlayersResponse?
}

struct PlayersResponse: Codable {
    var data: [Player]
}

struct Player: Codable {
    var id: String?
    var rel: String
    var name: String?
    var names: Names?
    var twitch: MediaPlatform?
    var youtube: MediaPlatform?
    var twitter: MediaPlatform?
    var speedrunslive: MediaPlatform?
}

struct RunPosition : Codable {
    var place: Int
    var run: Run
}

struct Run : Codable {
    var players: [Player]
    var times: Times
    var weblink: String
    var videos: Video?
    var values: [String : String]?
}


struct Times : Codable {
    var primary_t: TimeInterval
    var realtime_t: TimeInterval
}

struct Video : Codable {
    var links: [MediaPlatform]?
}

struct MediaPlatform : Codable {
    var uri: String?
}
