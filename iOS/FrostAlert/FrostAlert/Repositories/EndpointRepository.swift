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
    
    func loadData() {
        db.collection("endpoints").addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                self.endpoints = querySnapshot.documents.compactMap { document in
                    try? document.data(as: Endpoint.self) // try to decode data into Endpoint
                }
            }
        }
    }
    
    func addData(_ endpoint: Endpoint) {
        // db.collection("endpoints").addDocument(from: endpoint) // not used
    }
    
}
