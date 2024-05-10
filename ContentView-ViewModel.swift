//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Ricardo on 09/05/24.
//

import Foundation
import MapKit
import CoreLocation

extension ContentView{ // we are saing this is the view model for ContentView
    @Observable // reports back to any swiftui view that's watching
    class ViewModel{
        
        private(set) var locations: [Location] // in private(set) we’ve said that reading locations is fine, but only the class itself can write locations
        var selectedPlace: Location? //in addition, using this property to decide if we show the details sheet
        let savePath = URL.documentsDirectory.appending(path: "SavedPlaces")
        
        
        init() {
            do {
                let data = try Data(contentsOf: savePath) // get data to decode // var = try data(contenstof: location])
                locations = try JSONDecoder().decode([Location].self, from: data) //decode the data // var = try js.dec(object.self, from data)
            } catch {
                locations = [] //if fails return empty
            }
        }
        
        func addLocation(at point: CLLocationCoordinate2D){
            let newLocation = Location(id: UUID(), name: "New Location", description: "", latitude: point.latitude, longitude: point.longitude)
            locations.append(newLocation)
            save()
        }
        
        func update(location: Location){
            guard let selectedPlace else {return}
            
            if let index = locations.firstIndex(of: selectedPlace){
                locations[index] = location
            }
            save()
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(locations) // try to encode data // var = try json.encode(object)
                try data.write(to: savePath, options: [.atomic, .completeFileProtection]) // try to write data// try data.write(to: loc, options: [])
            } catch {
                print("Unable to save data.")
            }
        }
        
    }
}
