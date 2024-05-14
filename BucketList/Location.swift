//
//  Location.swift
//  BucketList
//
//  Created by Ricardo on 08/05/24.
//

import Foundation
import MapKit

struct Location: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var description: String
    var isFavorite: Bool = false
    var latitude: Double
    var longitude: Double
    var coordinate: CLLocationCoordinate2D{
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    #if DEBUG //avoit the example being built into App Store releases
    static let example = Location(id: UUID(), name: "Buckingham Palace", description: "Lit by over 40,000 lightbulbs", isFavorite: true, latitude: 51.501, longitude: -0.141)
    #endif
    
    // this custom function (==) saves us from comparing every property against every other property, which is wasteful, here we laverage that we have an ID property
    static func ==(lhs:Location, rhs: Location)-> Bool{
        lhs.id == rhs.id
    }
    
}
