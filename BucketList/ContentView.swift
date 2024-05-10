//
//  ContentView.swift
//  BucketList
//
//  Created by Ricardo on 08/05/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var locations = [Location]()
    
    //Also using this property to decide if we show the details sheet
    @State private var selectedPlace: Location?
    
    // Initial Position
    let startPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 56, longitude: -3), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)))
    
    
    var body: some View {
        
        //Wrapping on MapReader so we get Map Coordinates
        MapReader { proxy in
            Map(initialPosition: startPosition){
                ForEach(locations) { location in
                    Annotation(location.name, coordinate:location.coordinate){
                        Image(systemName: "heart.circle")
                            .resizable()
                            .foregroundStyle(.blue)
                            .frame(width: 44, height: 44)
                            .clipShape(.circle)
                        // mapview ususally gets confused between selecting a anotations and creating a new one, thats why we use a different gesture (long press)
                            .onLongPressGesture {
                                selectedPlace = location
                            }
                    }
                }
            }
                .onTapGesture {
                    position in
                    if let coordinate = proxy.convert(position, from: .local){
                        let newLocation = Location(id: UUID(), name: "New Location", description: "", latitude: coordinate.latitude, longitude: coordinate.longitude)
                        locations.append(newLocation)
                    }
                }
            
            // 
                .sheet(item: $selectedPlace) { place in // first we pass the selected place (it is an optional but swiftui unwrapp it for us)
                    
                    // in the edit view we find the location we want to edit and we replace it with the modified location
                    EditView(location: place) { newLocation in
                        if let index = locations.firstIndex(of: place){
                            locations[index] = newLocation
                        }
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
