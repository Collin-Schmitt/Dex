//
//  Persistence.swift
//  Dex
//
//  Created by Collin Schmitt on 12/11/24.
//

import CoreData

struct PersistenceController {
    //The thing that controls our database
    static let shared = PersistenceController()
    
    static var previewPokemon: Pokemon {
        let context = PersistenceController.preview.container.viewContext
        
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchRequest.fetchLimit = 1 //since we just need one pokemon for preview
        
        let results = try! context.fetch(fetchRequest)
        
        return results.first!
    }

    //controls our sample preview database
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let newPokemon = Pokemon(context: viewContext)
        newPokemon.id = 1
        newPokemon.name = "bulbasaur"
        newPokemon.types = ["grass", "poison"]
        newPokemon.hp = 45
        newPokemon.attack = 49
        newPokemon.defense = 49
        newPokemon.specialAttack = 65
        newPokemon.specialDefense = 65
        newPokemon.speed = 45
        newPokemon.spriteURL = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")
        newPokemon.shinyURL = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png")
        
        
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
        return result
    }()

    //The thing that holds the stuff (the database)
    let container: NSPersistentContainer

    //Just a regular init function
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Dex")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }else{
            container.persistentStoreDescriptions.first!.url =  FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.collinapps.DexGroup")!.appending(path: "Dex.sqlite")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print(error)
            }
        })
        //if duplicate, keep the one already in the DB and delete the new one (can crash app, or replace in DB if you wanted)
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
