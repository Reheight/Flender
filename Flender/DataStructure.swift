//
//  DataStructure.swift
//  Flender
//
//  Created by Palmatier, Dustin on 1/15/20.
//  Copyright © 2020 Hexham Network. All rights reserved.
//

class DataStructure {
    static var sharedInstance = DataStructure()
    
    private var displayName:String, externalId:String, bitmojiUrl:String;
    
    private init() {
        displayName = "3940ejfkfi9483jro39ut43jti943uh94u3hrif9ru3h4"
        externalId = "error"
        bitmojiUrl = "error"
    }
    
    func getDisplayName() -> String {
        return self.displayName
    }
    
    func getExternalId() -> String {
        return self.externalId
    }
    
    func getBitmojiUrl() -> String {
        return self.bitmojiUrl
    }
    
    func setDisplayName(string:String) {
        displayName = string
    }
    
    func setExternalId(string:String) {
        externalId = string
    }
    
    func setBitmojiUrl(string:String) {
        bitmojiUrl = string
    }
}
