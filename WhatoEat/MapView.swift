//
//  MapView.swift
//  WhatoEat
//  Version 2.0.1
//
//  Created by Ray Huang on 2024/11/25.
//

import SwiftUI

struct MapView: View {
    let location: String
    @Binding var isMapVisible: Bool

    var body: some View {
        VStack {
            Text(location == "後門" ? "後門地圖" : "宵夜街地圖")
                .font(.headline)
                .padding()
            Image(location == "後門" ? "back_door_map" : "supper_street_map")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .onTapGesture {
            isMapVisible = false
        }
    }
}

