//
//  EditView-ViewModel.swift
//  BucketList
//
//  Created by Ricardo on 14/05/24.
//

import Foundation

extension EditView {
    
    @Observable
    class ViewModel{
        enum LoadingState {
            case loading, loaded, failed
        }
        
        var name: String
        var description: String
        var isFavorite: Bool
        var location: Location //we get a location to edit
        var pages = [Page]()
        var loadingState = LoadingState.loading
        
        
        // we need inital values to display, but we cant just put placeholders, as we want to populate the the selected location, so we initalize like this:
        init(location: Location){ //@escaping means we are only calling this funcion when we press save rather than immediately
            self.location = location
            self.name = location.name
            self.description = location.description
            self.isFavorite = location.isFavorite
            
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
        
        func save() -> Location {
            var newLocation = location
            newLocation.name = name
            newLocation.description = description
            newLocation.isFavorite = isFavorite
            newLocation.id = UUID()
            return newLocation
        }
    }
}
