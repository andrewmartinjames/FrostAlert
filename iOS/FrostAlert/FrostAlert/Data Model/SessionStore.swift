//
//  SessionStore.swift
//  FrostAlert
//
//  Created by Andrew James on 5/26/21.
//

import Foundation
import SwiftUI
import Firebase
import Combine

class SessionStore: ObservableObject {
    static let shared = SessionStore()
    var didChange = PassthroughSubject<SessionStore, Never>()
    @Published var session: User? {didSet {self.didChange.send(self)}}
    var handle: AuthStateDidChangeListenerHandle?
    
    func listen() {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.session = User(
                    uid: user.uid,
                    displayName: user.displayName,
                    email: user.email
                )
                print("User added: \(self.session?.uid ?? "12") \(self.session?.email ?? "email")")
            } else {
                self.session = nil
                print("no session :(")
            }
        }
    }
    
    func isLoggedIn() -> Bool {
        if session?.uid != nil {
            return true
        }
        return false
    }
    
//    func
}
