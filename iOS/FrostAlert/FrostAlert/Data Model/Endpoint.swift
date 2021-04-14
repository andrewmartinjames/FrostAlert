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
}

