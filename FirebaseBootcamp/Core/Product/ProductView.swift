//
//  ProductView.swift
//  FirebaseBootcamp
//
//  Created by Kimleng Hor on 8/3/23.
//

import SwiftUI
import FirebaseFirestore

struct ProductView: View {
    
    @StateObject private var viewModel = ProductsViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.products) { product in
                ProductCellView(product: product)
                    .contextMenu {
                        Button("Add to favorites") {
                            viewModel.addUserFavoriteProduct(productId: product.id)
                        }
                    }
                
                if product == viewModel.products.last {
                    ProgressView()
                        .onAppear {
                            Task {
                                try? await viewModel.getProducts()
                            }
                        }
                }
            }
        }
        .navigationTitle("Products")
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu("Filter: \(viewModel.selectedFilter?.rawValue ?? "NONE")") {
                    ForEach(ProductsViewModel.FilterOption.allCases, id: \.self) { filterOption in
                        Button(filterOption.rawValue) {
                            Task {
                                do {
                                    try await viewModel.filterSelected(option: filterOption)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu("Category: \(viewModel.selectedCategory?.rawValue ?? "NONE")") {
                    ForEach(ProductsViewModel.CategoryOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            Task {
                                do {
                                    try await viewModel.categorySelected(option: option)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                }
            }
        })
        .task {
            try? await viewModel.getProducts()
//            viewModel.getProductsCount()
        }
    }
}

struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProductView()
        }
    }
}
