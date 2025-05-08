//
//  ContentView.swift
//  Dex
//
//  Created by Collin Schmitt on 12/11/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    //gives us access to the core DB manager (why we don't need a ViewModel)
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest<Pokemon>(sortDescriptors: []) private var allPokemon
    
    //fetching data from Core DB
    @FetchRequest<Pokemon>(
        //The data isn't going to be sorted in the DB, need sortDescripter to sort on screen
        sortDescriptors: [SortDescriptor(\.id)],
        animation: .default
    ) private var pokedex
    
    @State private var searchText = ""
    @State private var filterByFavorites: Bool = false
    
    let fetcher = FetchService()
    
    private var dynamicPredicate: NSPredicate {
        var predicates: [NSPredicate] = []
        
        //Search PRedicate
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name contains[c] %@", searchText))
        }
        
        //Filter by Favorite Predicate
        if filterByFavorites{
            predicates.append(NSPredicate(format: "favorite == %d", true))
        }
        
        //after we have both, combine the predicates
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    var body: some View {
        if allPokemon.isEmpty{
            //show the content unavailable view
            ContentUnavailableView {
                Label("No Pokemon", image: .nopokemon)
            } description: {
                Text("There aren't any Pokemon yet. \nFetch some Pokemon to get started!")
            } actions: {
                Button("Fetch Pokemon", systemImage: "antenna.radiowaves.left.and.right"){
                    getPokemon(from: 1)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        else{
            NavigationStack {
                List {
                    Section{
                        ForEach(pokedex) { pokemon in
                            NavigationLink(value: pokemon) {
                                if pokemon.sprite == nil {
                                    AsyncImage(url: pokemon.spriteURL){ image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                        
                                    }placeholder:{
                                        ProgressView()
                                    }
                                    .frame(width: 100, height: 100)
                                }
                                else{
                                    pokemon.spriteImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                }
                                
                                VStack(alignment: .leading){
                                    HStack{
                                        Text(pokemon.name!.capitalized)
                                            .fontWeight(.bold)
                                        
                                        if pokemon.favorite {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                    HStack{
                                        ForEach(pokemon.types!, id: \.self){ type in
                                            Text(type.capitalized)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.black)
                                                .padding(.horizontal, 13)
                                                .padding(.vertical, 5)
                                                .background(Color(type.capitalized))
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                            }
                            .swipeActions(edge: .leading){
                                Button(pokemon.favorite ? "Remove from Favorites": "Add to Favorites", systemImage: "star"){
                                    pokemon.favorite.toggle()
                                    
                                    //need to save to db
                                    do{
                                        try viewContext.save()
                                    } catch {
                                        print(error)
                                    }
                                }
                                .tint(pokemon.favorite ? .gray : .yellow)
                            }
                        }
                    } footer: {
                        if allPokemon.count < 151{
                            ContentUnavailableView {
                                Label("Missing Pokemon", image: .nopokemon)
                            } description: {
                                Text("The fetch was interrupted!\nFetch the rest of the Pokemon.")
                            } actions: {
                                Button("Fetch Pokemon", systemImage: "antenna.radiowaves.left.and.right"){
                                    getPokemon(from: pokedex.count + 1)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
                .navigationTitle("Pokedex")
                .searchable(text: $searchText, prompt: "Find a Pokemon")
                .autocorrectionDisabled()
                .onChange(of: searchText){
                    pokedex.nsPredicate = dynamicPredicate
                }
                .onChange(of: filterByFavorites){
                    pokedex.nsPredicate = dynamicPredicate
                }
                .navigationDestination(for: Pokemon.self) { pokemon in
                    PokemonDetail()
                        .environmentObject(pokemon)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button{
                            filterByFavorites.toggle()
                        } label: {
                            Label("Filter By Favorites", systemImage: filterByFavorites ? "star.fill" : "star")
                        }
                        .tint(.yellow)
                    }
                }
            }
        }
    }

    private func getPokemon(from id: Int) {
        Task{
            for i in id..<152 {
                do{
                    let fetchedPokemon = try await fetcher.fetchPokemon(i)
                    
                    let pokemon = Pokemon(context: viewContext)
                    pokemon.id = fetchedPokemon.id
                    pokemon.name = fetchedPokemon.name
                    pokemon.types = fetchedPokemon.types
                    pokemon.hp = fetchedPokemon.hp
                    pokemon.attack = fetchedPokemon.attack
                    pokemon.defense = fetchedPokemon.defense
                    pokemon.specialAttack = fetchedPokemon.specialAttack
                    pokemon.specialDefense = fetchedPokemon.specialDefense
                    pokemon.speed = fetchedPokemon.speed
                    pokemon.spriteURL = fetchedPokemon.spriteURL
                    pokemon.shinyURL = fetchedPokemon.shinyURL
          
                    
                    //save to db
                    try viewContext.save()
                    
                } catch{
                    print(error)
                }
            }
            
            //run function to store images to DB
            storeSprites()
        }
    }
    //function to save images to DB
    private func storeSprites() {
        Task{
            do {
                //go through all pokemon and store the images
                for pokemon in allPokemon {
                    
                    pokemon.sprite = try await URLSession.shared.data(from: pokemon.spriteURL!).0 //grabbing just data (not response)
                    pokemon.shiny = try await URLSession.shared.data(from: pokemon.shinyURL!).0
                    
                    try viewContext.save()
                    
                    print("Sprites stored: \(pokemon.id): \(pokemon.name!.capitalized)")
                }
            } catch {
                print(error)
            }
        }
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
