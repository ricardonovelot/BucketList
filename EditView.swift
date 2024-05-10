//
//  EditView.swift
//  BucketList
//
//  Created by Ricardo on 09/05/24.
//

import SwiftUI

enum LoadingState{
    case loading, loaded, failed
}

struct EditView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var loadingState = LoadingState.loading
    @State private var pages = [Page]()
    
    //we get a location to edit
    var location: Location
    
    // this poperty ask for a function that accepts a single location and returns nothing, whe want to pass back wathever new location we want
    var onSave: (Location) -> Void
    
    @State private var name: String
    @State private var description: String
    
    
    // we need inital values to display, but we cant just put placeholders, as we want to populate the the selected location, so we initalize like this:
    init(location: Location, onSave: @escaping (Location)-> Void){ //@escaping means we are only calling this funcion when we press save rather than immediately
        self.location = location
        self.onSave = onSave
        
        _name = State(initialValue: location.name) // we use State structs
        _description = State(initialValue: location.description) // we use the same underscore technic as with SwiftData
    }
    
    var body: some View {
        NavigationStack{
            Form {
                Section{
                    TextField("Place Name", text: $name)
                    TextField("Description", text: $description)
                }
                Section("Nearby…") {
                    switch loadingState {
                    case .loaded:
                        ForEach(pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline)
                            + Text(": ") +
                            Text(page.description)
                                .italic()
                        }
                    case .loading:
                        Text("Loading…")
                    case .failed:
                        Text("Please try again later.")
                    }
                }
            }
            .navigationTitle("Place details")
            .toolbar {
                Button("Save"){
                    // we copy the location
                    var newLocation = location
                    
                    // then we modify the properties we want modified
                    newLocation.id = UUID() // the id changes with every modification because we need swiftui to bother update the map, if they are equal its not going to update it
                    newLocation.name = name
                    newLocation.description = description
                    
                    // we send back the location with adjustments
                    onSave(newLocation)
                    
                    
                    dismiss()
                }
            }
            .task { // as soon as the view appears it loads nearby places
                await fetchNearbyPlaces()
            }
        }
    }
    
    func fetchNearbyPlaces() async {
        
        // wikipedia string
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.latitude)%7C\(location.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
        
        // we build the url
        guard let url = URL(string: urlString) else {
            print("Bad URL: \(urlString)")
            return
        }

        // get the data from the url, decode the JSON in to our Result Struct
        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            
            let items = try JSONDecoder().decode(Result.self, from: data)

            // if success – convert the array values to our pages array
            pages = items.query.pages.values.sorted()
            loadingState = .loaded
        } catch {
            // if we're still here it means the request failed
            loadingState = .failed
        }
    }
    
}

#Preview {
    // our preview use loads the example
    EditView(location: .example) { _ in // because the function we are using to store the new location
    }
}
