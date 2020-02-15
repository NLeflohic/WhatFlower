//
//  FlowerManager.swift
//  WhatFlower
//
//  Created by nicolas le flohic on 14/02/2020.
//  Copyright © 2020 nicolas le flohic. All rights reserved.
//

import Foundation

protocol FlowerManagerDelegate {
    func didSearchFinishing (data: FlowerQuery)
}

struct FlowerManager {
    
    var delegate : FlowerManagerDelegate?
    
//    let url = "https://en.wikipedia.org/w/api.php?action=query&list=search&format=json&titles=flowerName&srlimit=1&srsearch="
let url="https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts%7Cpageimages&explaintext=&redirects=1&exintro=&indexpageids=&pithumbsize=500&titles="
    
    func fetchData (flowerToFind: String) {
        let flowerToSearch = flowerToFind.replacingOccurrences(of: " ", with: "%20")
        let urlApi = url + flowerToSearch
        if let urlString = URL(string: urlApi){
            if let data = try? Data(contentsOf: urlString) {
            parseJSON (data: data)
            }
        } else {
            print ("error while parsing url")
        }
    }
    
    func parseJSON (data: Data) {
//        let decoder = JSONDecoder()
//        do {
//            let result = try decoder.decode(Flower.self, from: data)
//            let searchQuery = result.query
//            print ("end search Query")
//            delegate?.didSearchFinishing (data: searchQuery)
//        } catch {
//            print (error.localizedDescription)
//        }
        let flowerJSON : JSON = JSON(data)
        let pageID = flowerJSON["query"]["pageids"][0].stringValue
        let titleFlower = flowerJSON["query"]["pages"][pageID]["title"].stringValue
        let description = flowerJSON["query"]["pages"][pageID]["extract"].stringValue
        let imageUrl = flowerJSON["query"]["pages"][pageID]["thumbnail"]["source"].stringValue
        let flowerQuery = FlowerQuery(title: titleFlower, description: description, urlImage: imageUrl)
        delegate?.didSearchFinishing(data: flowerQuery)
        
    }
    
    
}

struct FlowerQuery {
    var title : String
    var description: String
    var urlImage: String
}

struct Flower: Decodable {
    var query : Query
}

struct Query : Decodable {
    var search : [Search]
}

struct Search: Decodable {
    var title : String
    var snippet : String
}
