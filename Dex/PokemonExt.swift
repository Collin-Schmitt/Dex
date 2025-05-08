//
//  PokemonExt.swift
//  Dex
//
//  Created by Collin Schmitt on 12/20/24.
//

//used to extend the Core Data model


import SwiftUI

extension Pokemon {
    
    var spriteImage: Image {
        //is there data actually stored in our sprite property, then take that data and turn it into a UI image and store it in an image property
        if let data = sprite, let image = UIImage(data: data) {
            Image(uiImage: image)
        }
        else { //hopefully the else's will never been seen on the screen
            Image(.bulbasaur)
        }
    }
    
    var shinyImage: Image{
        if let data = shiny, let image = UIImage(data: data) {
            Image(uiImage: image)
        }
        else{
            Image(.shinybulbasaur)
        }
    }
    
    var background: ImageResource {
        switch types![0]{
        case "rock", "ground", "steel", "fighting", "ghost", "dark", "pyschic":
                .rockgroundsteelfightingghostdarkpsychic
        case "fire", "dragon":
                .firedragon
        case "flying", "bug":
                .flyingbug
        case "ice":
                .ice
        case "water":
                .water
            
        default:
                .normalgrasselectricpoisonfairy
        }
    }
    
    //Pokemon stats
    var typeColor: Color {
        (Color(types![0].capitalized))
    }
    
    var stats: [Stat] {
        [
            Stat(id: 1, name: "HP", value: hp),
            Stat(id: 2, name: "Attack", value: attack),
            Stat(id: 3, name: "Defense", value: defense),
            Stat(id: 4, name: "Special Attack", value: specialAttack),
            Stat(id: 5, name: "Special Defense", value: specialDefense),
            Stat(id: 6, name: "Speed", value: speed)

        ]
    }
    //computed property to grab the highest stat value
    var highestStat: Stat{
        stats.max{ stat1, stat2 in
            stat1.value < stat2.value
        }!
    }
    
}

struct Stat: Identifiable {
    let id : Int
    let name: String
    let value: Int16
}
