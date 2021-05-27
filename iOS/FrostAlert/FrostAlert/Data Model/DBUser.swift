//
//  DBUser.swift
//  FrostAlert
//
//  Created by Andrew James on 5/26/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUser: Identifiable, Codable {
    @DocumentID var id: String?
    var uid: String
    var endpoint: String
    var threshold_temp: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case uid = "uid"
        case endpoint = "endpoint"
        case threshold_temp = "threshold_temp"
    }
}

