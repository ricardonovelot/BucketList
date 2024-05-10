//
//  WikipediaResult.swift
//  BucketList
//
//  Created by Ricardo on 09/05/24.
//

import Foundation

struct Result: Codable {
    let query: Query // Query type?
}

struct Query: Codable {
    let pages: [Int: Page] // dictionary of integers and pages
}

struct Page: Codable, Comparable { // we are immplementing our own custom sorting
    let pageid: Int
    let title: String
    let terms: [String: [String]]?
    var description: String {
        terms?["description"]?.first ?? "No further information"
    } // sometimes there might not be a description key or it may be empty
    
    // to confirm comparable we must implement a < function that accepts two parameters of the type of our struct, and returns true if the first should be sorted before the second.
    static func <(lhs: Page, rhs: Page) -> Bool {
        lhs.title < rhs.title
    }
}
