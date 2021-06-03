//
//  DBDocuments.swift
//  FrostAlert
//
//  Created by Andrew James on 5/26/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


class DBDocuments: ObservableObject {
    let db = Firestore.firestore()
    @Published var endpoint: Endpoint?
    @Published var dbuser: DBUser?
    @Published var deviceID: String?
    
    func loadDBUser(uid: String) {
        db.collection("users").document(uid)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                print("Current data: \(data)")
                let result = Result {
                    try self.dbuser = document.data(as: DBUser.self)
                }
                switch result {
                    case .success( _):
                        print("User loaded")
                        self.loadEndpoint()
                    case .failure(let error):
                        print("Error decoding: \(error)")
                }
            }
    }
    
    func loadEndpoint() {
        print("loadendpoint started")
        guard self.dbuser?.endpoint != nil else {
            print("no endpoint name available")
            return
        }
        self.deviceID = self.dbuser!.endpoint
        if deviceID != "" {
            db.collection("endpoints").document(deviceID!)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                print("Current data: \(data)")
                let result = Result {
                    try self.endpoint = document.data(as: Endpoint.self)
                }
                switch result {
                    case .success( _):
                        print("Endpoint loaded")
                    case .failure(let error):
                        print("Error decoding: \(error)")
                }
            }
        } else {
            print("no endpoint registered")
        }
    }
    
    func changeTempThreshold(newThreshold: Double) {
        guard let uid = self.dbuser?.uid else {
            print("Endpoint name load failed")
            return
        }
        if uid != "" {
            db.collection("users").document(uid).updateData(["threshold_temp": newThreshold])
        }
    }
    
    func setDevice(deviceID: String) {
        guard let uid = self.dbuser?.uid else {
            print("Endpoint name load failed")
            return
        }
        if uid != "" {
            db.collection("users").document(uid).updateData(["endpoint": deviceID])
            db.collection("endpoints").document(deviceID).updateData(["user": uid])
        }
    }
    
    
    func setFCMToken(fcmToken: String) {
        guard let uid = self.dbuser?.uid else {
            print("Endpoint name load failed")
            return
        }
        if uid != "" {
            db.collection("users").document(uid).updateData(["fcm_token": fcmToken])
        }
        
    }
}

