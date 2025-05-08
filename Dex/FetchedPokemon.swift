//
//  FetchedPokemon.swift
//  Dex
//
//  Created by Collin Schmitt on 12/11/24.
//

import Foundation

struct FetchedPokemon: Decodable {
    let id: Int16
    let name: String
    let types: [String]
    let hp: Int16
    let attack: Int16
    let defense: Int16
    let specialAttack: Int16
    let specialDefense: Int16
    let speed: Int16
    let spriteURL: URL
    let shinyURL: URL
    //this model is specifically for the data we capture online (no favorite property here)
    
    //since our property names don't fully line up with the names in JSON data, need to adjust
    enum CodingKeys: CodingKey {
        case id
        case name
        case types
        case stats
        case sprites
        
        enum TypeDictionaryKeys: CodingKey {
            case type
            
            enum TypeKeys: CodingKey {
                case name
            }
        }
        
        enum StatDictionaryKeys: CodingKey{
            case baseStat
        }
        
        enum SpriteKeys: String, CodingKey {
            case spriteURL = "frontDefault"
            case shinyURL = "frontShiny"
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int16.self, forKey: .id)
        
        name = try container.decode(String.self, forKey: .name)
        
        //create a temp property to hold our types as we decode them
        var decodedTypes: [String] = []
        //need to create a new container
        var typesContainer = try container.nestedUnkeyedContainer(forKey: .types) //unkeyed since it's an array (look at json data)
        while !typesContainer.isAtEnd { //looping through everything and decode until the end of the typesContainer
            //decode types (Need to go another level into the dictionary container (again look at json data))
            let typesDictionaryContainer = try typesContainer.nestedContainer(keyedBy: CodingKeys.TypeDictionaryKeys.self)
            
            //need to go to one more container to get type value
            let typeContainer = try typesDictionaryContainer.nestedContainer(keyedBy: CodingKeys.TypeDictionaryKeys.TypeKeys.self, forKey: .type)
            
            //now we can grab that actual type value
            let type = try typeContainer.decode(String.self, forKey: .name)
            decodedTypes.append(type) //adding each type to decoded types array
        }
        
        //check if there is two types. If first type is normal (want the other type to be primary type
        if decodedTypes.count == 2 && decodedTypes[0] == "normal" {
            let tempType = decodedTypes[0]
             decodedTypes[0] = decodedTypes[1]
             decodedTypes[1] = tempType
        }
        
        //once done looping, assign types to the decodedTypes array
        types = decodedTypes
        
        var decodedStats: [Int16] = []
        var statsContainer = try container.nestedUnkeyedContainer(forKey: .stats)
        while !statsContainer.isAtEnd {
            let statsDictionaryContainer = try statsContainer.nestedContainer(keyedBy: CodingKeys.StatDictionaryKeys.self)
            
            let stat = try statsDictionaryContainer.decode(Int16.self, forKey: .baseStat)
            
            decodedStats.append(stat)
        }
        hp = decodedStats[0]
        attack = decodedStats[1]
        defense = decodedStats[2]
        specialAttack = decodedStats[3]
        specialDefense = decodedStats[4]
        speed = decodedStats[5]
        
        let spriteContainer = try container.nestedContainer(keyedBy: CodingKeys.SpriteKeys.self, forKey: .sprites)
        spriteURL = try spriteContainer.decode(URL.self, forKey: .spriteURL)
        shinyURL = try spriteContainer.decode(URL.self, forKey: .shinyURL)
    }
}
