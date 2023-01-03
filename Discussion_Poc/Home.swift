//
//  Home.swift
//  Discussion_Poc
//
//  Created by Loïc MAZUC on 20/09/2022.
//

import SwiftUI

struct Home: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: ChatView()) {
                Text("Go to discussion")
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
