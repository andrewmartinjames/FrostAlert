//
//  EndpointRepository.swift
//  FrostAlert
//
//  Created by Andrew James on 4/13/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class EndpointRepository: ObservableObject {
    let db = Firestore.firestore()
    @Published var endpoints = [Endpoint]()
    
    func loadEndpoints() {
        db.collection("endpoints").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                return
            }
            self.endpoints = documents.compactMap { (queryDocumentSnapshot) -> Endpoint? in
                return try? queryDocumentSnapshot.data(as: Endpoint.self)
            }
        }
    }
    
    func addData(_ endpoint: Endpoint) {
        // db.collection("endpoints").addDocument(from: endpoint) // not used
    }
    
}
