//
//  ContentView.swift
//  koetann
//
//  Created by 田中志門 on 12/21/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            CommunityView()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Community")
                }

            SettingView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    ContentView()
}
