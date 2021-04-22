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
    @DocumentID var id: String? = UUID().uuidString
    var currentHum: Double
    var currentTemp: Double
    
    enum CodingKeys: String, CodingKey {
        case currentHum = "current_hum"
        case currentTemp = "current_temp"
    }
}

