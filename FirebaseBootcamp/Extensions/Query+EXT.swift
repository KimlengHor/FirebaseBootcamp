//
//  Query+EXT.swift
//  FirebaseBootcamp
//
//  Created by Kimleng Hor on 8/6/23.
//

import Foundation
import Firebase
import Combine

extension Query {
    
    func getDocuments<T>(type: T.Type) async throws -> [T] where T: Decodable {
        try await getDocumentsWithSnapshot(type: type).products
    }
    
    func getDocumentsWithSnapshot<T>(type: T.Type) async throws -> (products: [T], lastDocument: DocumentSnapshot?) where T: Decodable {
        let snapshot = try await self.getDocuments()
        
        let products = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        
        return (products, snapshot.documents.last)
    }
    
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else { return self }
        return self.start(afterDocument: lastDocument)
    }
    
    func aggregateCount() async throws -> Int {
        let snapshot = try await self.count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
    
    func addSnapshotListener<T>(as type: T.Type) -> (AnyPublisher<[T], Error>, ListenerRegistration) where T: Decodable {
        let publisher = PassthroughSubject<[T], Error>()
        let listener = self.addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("No documents")
                return
            }
            
            let items: [T] = documents.compactMap { doc in
                return try? doc.data(as: T.self)
            }
            
            publisher.send(items)
            
        }
        return (publisher.eraseToAnyPublisher(), listener)
    }
}


