//
//  ContentView.swift
//  BucketList
//
//  Created by Ricardo on 08/05/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    // all the properties of contentview in our viewModel
    @State private var viewModel = ViewModel()
  
    
    // Initial Position
    let startPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 56, longitude: -3), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)))
    
    
    var body: some View {
        
        //Wrapping on MapReader so we get Map Coordinates
        MapReader { proxy in
            Map(initialPosition: startPosition){
                ForEach(viewModel.locations) { location in
                    Annotation(location.name, coordinate:location.coordinate){
                        Image(systemName: "heart.circle")
                            .resizable()
                            .foregroundStyle(.blue)
                            .frame(width: 44, height: 44)
                            .clipShape(.circle)
                        // mapview ususally gets confused between selecting a anotations and creating a new one, thats why we use a different gesture (long press)
                            .onLongPressGesture {
                                viewModel.selectedPlace = location
                            }
                    }
                }
            }
                .onTapGesture {
                    position in
                    if let coordinate = proxy.convert(position, from: .local){
                        viewModel.addLocation(at: coordinate)
                    }
                }
            
            // 
                .sheet(item: $viewModel.selectedPlace) { place in // first we pass the selected place (it is an optional but swiftui unwrapp it for us)
                    
                    // in the edit view we find the location we want to edit and we replace it with the modified location
                    EditView(location: place) {
                        viewModel.update(location: $0)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
