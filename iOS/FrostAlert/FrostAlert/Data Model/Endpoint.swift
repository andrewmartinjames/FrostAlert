//
//  Endpoint.swift
//  FrostAlert
//
//  Created by Andrew James on 4/13/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Endpoint: Identifiable, Codable {
    @DocumentID var id: String?
    var currentHum: Double
    var currentTemp: Double
    var user: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case currentHum = "current_hum"
        case currentTemp = "current_temp"
        case user = "user"
    }
}

