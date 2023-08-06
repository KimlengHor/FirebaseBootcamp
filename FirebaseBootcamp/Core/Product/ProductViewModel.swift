//
//  ProductViewModel.swift
//  FirebaseBootcamp
//
//  Created by Kimleng Hor on 8/6/23.
//

import Foundation
import SwiftUI
import Firebase

@MainActor
final class ProductsViewModel: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published var selectedFilter: FilterOption? = nil
    @Published var selectedCategory: CategoryOption? = nil
    
    private var lastDocument: DocumentSnapshot? = nil
    
    enum FilterOption: String, CaseIterable {
        case noFilter
        case priceHigh
        case priceLow
        
        var priceDescending: Bool? {
            switch self {
            case .noFilter: return nil
            case .priceHigh: return true
            case .priceLow: return false
            }
        }
    }
    
    func filterSelected(option: FilterOption) async throws {
        self.selectedFilter = option
        self.products.removeAll()
        self.lastDocument = nil
        try? await getProducts()
    }
    
    enum CategoryOption: String, CaseIterable {
        case noCategory
        case smartphones
        case laptops
        case fragrances
        
        var categoryKey: String? {
            if self == .noCategory {
                return nil
            } else {
                return self.rawValue
            }
        }
    }
    
    func categorySelected(option: CategoryOption) async throws {
        
        self.selectedCategory = option
        self.products.removeAll()
        self.lastDocument = nil
        try? await getProducts()
    }
    
    func getProducts() async throws {
        let(newProducts, lastDocument) = try await ProductsManager.shared.getAllProducts(descending: selectedFilter?.priceDescending, category: selectedCategory?.categoryKey, count: 10, lastDocument: lastDocument)
        
        self.products.append(contentsOf: newProducts)
        
        if let lastDocument {
            self.lastDocument = lastDocument
        }
    }
    
    func getProductsByRating() {
        Task {
            let (newProducts, lastDocument) = try await ProductsManager.shared.getProductsByDocument(count: 3, lastDocument: lastDocument)
            self.products.append(contentsOf: newProducts)
            self.lastDocument = lastDocument
        }
    }
    
    func getProductsCount() {
        Task {
            let count = try await ProductsManager.shared.getAllProductCount()
            print("ALL PRODUCT COUNT: \(count)")
        }
    }
    
    func addUserFavoriteProduct(productId: Int) {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try await UserManager.shared.addUserFavoriteProduct(userId: authDataResult.uid, productId: productId)
        }
    }
}
