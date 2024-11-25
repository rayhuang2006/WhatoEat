//
//  St.swift
//  WhatoEat
//  Version 2.0.1
//
//  Created by Ray Huang on 2024/11/25.
//

import SwiftUI

struct StoreCard: View {
    let store: Store
    @Binding var isTextVisible: Bool
    @State private var isFlipped: Bool = false

    var body: some View {
        ZStack {
            VStack {
                Text(store.name)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .opacity(isTextVisible ? 1 : 0) // 控制文字顯示
            }
            .frame(width: 300, height: 300)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .opacity(isFlipped ? 0 : 1)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )

            VStack {
                Text(store.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                    .opacity(isTextVisible ? 1 : 0) // 控制文字顯示
            }
            .frame(width: 300, height: 300)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .opacity(isFlipped ? 1 : 0)
            .rotation3DEffect(
                .degrees(isFlipped ? 0 : -180),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.5)) {
                isFlipped.toggle()
            }
        }
    }
}
