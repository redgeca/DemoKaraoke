//
//  SongRequest.swift
//  DemoKaraoke
//
//  Created by Réjean Caron on 17-11-14.
//  Copyright © 2017 Productions Redge. All rights reserved.
//

import UIKit

public struct SongRequest: Codable {
    
    let id : Int;
    let songId : Int;
    let song : Song;
    let singerName : String?; 
    let requestTime : String;
    let notes : String?;
   
    /*
    init(pRequestId: Int, pSongId : Int, pSong : Song, pSingerName: String, pRequestTime: String, pNotes: String) {
        id = pRequestId;
        songId = pSongId;
        song = pSong;
        singerName = pSingerName;
        requestTime = pRequestTime
        notes = pNotes;
    }
    */
}

public struct PlaylistSong: Codable {
    let id: Int;
    let requestId: Int;
    let request: SongRequest;
    let playOrder: Int;
    let isDone: Int;
    
}

public struct  Song: Codable {
    let id : Int;
    let title : String;
    let artistId : Int;
    let artist : Artist?;
    let categoryName : String?;
    let tagsName : String?;
    let content : String?;

    /*
    init(pSongId : IntMax, pTitle: String, pCategoryId : IntMax, pCategory : String, pArtistId : IntMax, pArtist : Artist, pCategoryName : String, pTagsName : String, pContent:String) {
        id = pSongId;
        title = pTitle;
        categoryId = pCategoryId
        category = pCategory;
        artistId = pArtistId;
        artist = pArtist;
        categoryName = pCategoryName;
        tagsName = pTagsName;
        content = pContent;
    }
 */
}

public struct  Artist: Codable {
    let id : Int;
    let name : String;
    let songs : [Song]?;
    
    /*
    init(pArtistId : IntMax, pName : String, pSongs : [Song]) {
        id = pArtistId;
        name = pName;
        songs = pSongs;
    }
    */
}

public struct State: Codable  {
    let id: Int;
    let value: String;
    
}

public struct TableViewInformation {
    let fromTableView : UITableView
    let indexPath : IndexPath
}

