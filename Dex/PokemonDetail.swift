//
//  PokemonDetail.swift
//  Dex
//
//  Created by Collin Schmitt on 12/13/24.
//

import SwiftUI

struct PokemonDetail: View {
    //same as in the contentview file
    @Environment(\.managedObjectContext) private var viewContext

    @State private var showShiny = false
    
    //how to pass the same pokemon throughout the environement (using db)
    @EnvironmentObject private var pokemon: Pokemon
    
    var body: some View {
        ScrollView {
            ZStack {
                Image(pokemon.background)
                    .resizable()
                    .scaledToFit( )
                    .shadow(color: .black, radius: 6)
                
                if pokemon.sprite == nil || pokemon.shiny == nil{
                    //pokemon sprite (dont have imagees, but have urls
                    AsyncImage(url: showShiny ? pokemon.shinyURL : pokemon.spriteURL) { image in
                        image
                            .interpolation(.none)
                            .resizable( )
                            .scaledToFit()
                            .padding(.top, 50)
                            .shadow(color: .black, radius: 6)
                    } placeholder: {
                        ProgressView()
                    }
                } else{
                    (showShiny ? pokemon.shinyImage : pokemon.spriteImage)
                        .interpolation(.none)
                        .resizable( )
                        .scaledToFit()
                        .padding(.top, 50)
                        .shadow(color: .black, radius: 6)
                }
            }
            
            HStack{
                ForEach(pokemon.types!, id: \.self) { type in
                    Text(type.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .shadow(color: .white, radius: 1)
                        .padding(.vertical, 7)
                        .padding(.horizontal)
                        .background(Color(type.capitalized))
                        .clipShape(.capsule)
                        
                }
                
                Spacer()
                
                //favorite button
                Button {
                    pokemon.favorite.toggle()
                    
                    do{
                        try viewContext.save( )
                    }catch{
                        print(error)
                    }
                } label: {
                    Image(systemName: pokemon.favorite ? "star.fill" : "star")
                        .font(.largeTitle)
                        .tint(.yellow)
                }
            }
            .padding()
            
            Text("Stats")
                .font(.title)
                .padding(.bottom, -7)
            
            Stats(pokemon: pokemon)
        }
        .navigationTitle(pokemon.name!.capitalized)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing){
                Button{
                    showShiny.toggle( )
                } label: {
                    Image(systemName: showShiny ? "wand.and.stars" : "wand.and.stars.inverse")
                        .tint(showShiny ? .yellow : .primary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        PokemonDetail()
            .environmentObject(PersistenceController.previewPokemon)
    }
}
