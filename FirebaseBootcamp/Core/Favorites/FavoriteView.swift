//
//  FavoriteView.swift
//  FirebaseBootcamp
//
//  Created by Kimleng Hor on 8/5/23.
//

import SwiftUI
import Combine


struct FavoriteView: View {
    
    @StateObject private var viewModel = FavoriteViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.userFavoriteProducts, id: \.id.self) { item in
                ProductCellViewBuilder(productId: String(item.productId))
                    .contextMenu {
                        Button("Remove from favorites") {
                            viewModel.removeFromFavorites(favoriteProductId: item.id)
                        }
                    }
            }
        }
        .navigationTitle("Favorites")
        .onFirstAppear {
            try? viewModel.addListenerForFavorites()
        }
    }
}

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FavoriteView()
        }
    }
}


