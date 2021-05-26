//
//  User.swift
//  FrostAlert
//
//  Created by Andrew James on 5/26/21.
//

import Foundation

class User {
    var uid: String
    var email: String?
    var displayName: String?
    
    init(uid: String, displayName: String?, email: String?) {
        self.uid = uid
        self.displayName = displayName
        self.email = email
    }
}
