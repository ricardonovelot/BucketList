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
    
    @Namespace private var mapScope
    
    // Initial Position
    let startPosition = MapCameraPosition.userLocation(fallback: .automatic)
    
    
    var body: some View {
        if viewModel.isUnlocked{
            ZStack{
                //Wrapping on MapReader so we get Map Coordinates
                MapReader { proxy in
                    Map(initialPosition: startPosition,scope: mapScope){
                        ForEach(viewModel.filteredLocations) { location in
                            Annotation(location.name, coordinate:location.coordinate){
                                Image(systemName: "mappin.circle.fill")
                                    .resizable()
                                    .foregroundStyle(.red)
                                    .background(.white)
                                    .frame(width: 32, height: 32)
                                    .clipShape(.circle)
                                    .onLongPressGesture {// mapview ususally gets confused between selecting a anotations and creating a new one, thats why we use a different gesture (long press)
                                        viewModel.selectedPlace = location
                                    }
                                    
                            }
                            
                        }
                        UserAnnotation()
                    }
                
                    
                    .onAppear{
                        viewModel.manager.requestWhenInUseAuthorization()
                    }
                    
//                    .onChange(of: viewModel.filterOption) { newOption in
//                        //Create your action here..
//                    }
                    
                    .onTapGesture {
                        position in
                        if let coordinate = proxy.convert(position, from: .local){
                            
                                viewModel.addLocation(at: coordinate)
                                viewModel.selectedPlace = viewModel.locations.last
                            
                        }
                    }
                    
                    .sheet(item: $viewModel.selectedPlace) { place in // first we pass the selected place (it is an optional but swiftui unwrapp it for us)
                        
                        // in the edit view we find the location we want to edit and we replace it with the modified location
                        EditView(location: place) {
                            viewModel.update(location: $0)
                        }
                    }
                    .mapStyle(viewModel.selectedMapStyle)
                    
                    .mapControls({
                        MapScaleView()
                    })
                    
                    .safeAreaInset(edge: .trailing){
                        VStack{
                            VStack(spacing:0){
                                VStack(){
                                    Menu {
                                        Picker("Options", selection: $viewModel.filterOption) {
                                            ForEach(viewModel.filterOptions, id: \.self) { option in
                                                            Text(option)
                                                        }
                                                    }
                                        
                                    } label: {
                                        Image(systemName: "line.3.horizontal.decrease.circle")
                                            .font(.title3)
                                            .fontWeight(.light)
                                            .frame(height: 44)
                                    }
                                    
                                }
                            
                                Divider()
                                
                                VStack(){
                                    Menu {
                                        Button(action: {
                                            viewModel.selectedMapStyle = .standard
                                        }) {
                                            Label("Default", systemImage: "map")
                                        }
                                        
                                        Button(action: {
                                            viewModel.selectedMapStyle = .imagery
                                        }) {
                                            Label("Satelite", systemImage: "globe.americas")
                                        }
                                        
                                        Button(action: {
                                            viewModel.selectedMapStyle = .hybrid
                                        }) {
                                            Label("Hibrid", systemImage: "square.stack.3d.up")
                                        }
                                        
                                    } label: {
                                        Image(systemName: "square.3.layers.3d")
                                            .font(.title3)
                                            .fontWeight(.light)
                                            .frame(height: 44)
                                    }
                                    
                                }
                                .padding(.top,2)
                                Divider()
                                MapUserLocationButton(scope: mapScope)
                                    .mapControlVisibility(.visible)
                            }
                            .background(.thickMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(width: 44)
                            .shadow(color: .black.opacity(0.15), radius: 20)
                            
                            
                            MapPitchToggle(scope: mapScope)
                                .mapControlVisibility(.visible)
                            
                            MapCompass(scope: mapScope)
                            Spacer()
                        }
                        .buttonBorderShape(.roundedRectangle)
                        .padding(.trailing, 16)
                        
                    }.mapScope(mapScope)
                }
                
            }
        } else {
            Button("Unlock Places", action: viewModel.authenticate)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.capsule)
        }
    }
}


#Preview {
    ContentView()
}
