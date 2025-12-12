//
//  ContentView.swift
//  OuickShop by Mystore
//
//  Created by Purna Jear on 05/05/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .environmentObject(HomeViewModel())
        .environmentObject(CartViewModel())
        .environmentObject(UserViewModel())
}
