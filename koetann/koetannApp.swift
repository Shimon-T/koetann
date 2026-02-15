//
//  koetannApp.swift
//  koetann
//
//  Created by 田中志門 on 12/21/25.
//

import SwiftUI
import SwiftData

@main
struct koetannApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [WordBook.self, Card.self])
    }
}
