//
//  ContentView.swift
//  WhatoEat
//
//  Created by Ray Huang on 2024/11/17.
//

import SwiftUI

struct ContentView: View {
    @State private var stores: [Store] = []
    @State private var selectedIndex: Int = 1
    @State private var isRandomizing: Bool = false
    @State private var location: String = "後門" // 預設顯示後門

    var body: some View {
        VStack {

            if stores.isEmpty {
                Text("載入中...")
                    .font(.headline)
                    .padding()
            } else {
                TabView(selection: $selectedIndex) {
                    ForEach(0..<stores.count, id: \.self) { index in
                        StoreCard(store: stores[index])
                            .tag(index)
                            .frame(width: 300, height: 300)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .onChange(of: selectedIndex) {
                    handleInfiniteScrolling()
                }
                Button(action: toggleLocation) {
                    Text(location)
                        .font(.headline)
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(Color.gray.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.bottom, 5)

                Button(action: randomizeCard) {
                    Text("開始抽一家店")
                        .font(.headline)
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.top, 20)
                .disabled(isRandomizing)
            }
        }
        .padding()
        .onAppear {
            self.stores = createInfiniteStores(from: loadStoresFromCSV(fileName: "information"))
        }
    }

    /// 處理無限滑動
    private func handleInfiniteScrolling() {
        if !isRandomizing {
            if selectedIndex == 0 {
                DispatchQueue.main.async {
                    withAnimation(.none) {
                        selectedIndex = stores.count - 2
                    }
                }
            } else if selectedIndex == stores.count - 1 {
                DispatchQueue.main.async {
                    withAnimation(.none) {
                        selectedIndex = 1
                    }
                }
            }
        }
    }

    /// 創建無限循環的數據列表
    private func createInfiniteStores(from originalStores: [Store]) -> [Store] {
        guard !originalStores.isEmpty else { return [] }
        var infiniteStores = originalStores
        infiniteStores.insert(originalStores.last!, at: 0)
        infiniteStores.append(originalStores.first!)
        return infiniteStores
    }

    /// 隨機選擇一張名片
    private func randomizeCard() {
        guard !stores.isEmpty else { return }
        isRandomizing = true
        let totalSteps = 6 // 定義動畫步數
        var step = 0

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if step < totalSteps {
                withAnimation(.easeInOut(duration: 0.5)) {
                    selectedIndex = Int.random(in: 1..<(stores.count - 1))
                }
                step += 1
            } else {
                timer.invalidate()
                isRandomizing = false
            }
        }
    }

    /// 切換數據來源
    private func toggleLocation() {
        // 切換地點名稱
        location = (location == "後門") ? "宵夜街" : "後門"
        // 根據當前地點讀取對應的數據
        let fileName = (location == "後門") ? "back_door" : "information"
        stores = createInfiniteStores(from: loadStoresFromCSV(fileName: fileName))
        // 重設選中的索引
        selectedIndex = 1
    }
}

struct StoreCard: View {
    let store: Store
    @State private var isFlipped: Bool = false

    var body: some View {
        ZStack {
            VStack {
                Text(store.name)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
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

struct Store: Identifiable {
    let id = UUID()
    let name: String
    let description: String
}

/// CSV 讀取功能
func loadStoresFromCSV(fileName: String) -> [Store] {
    var stores: [Store] = []
    
    guard let filePath = Bundle.main.path(forResource: fileName, ofType: "csv") else {
        print("無法找到 \(fileName).csv 檔案")
        return stores
    }
    
    do {
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)
        
        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).isEmpty { continue }
            let components = splitCSVLine(line: line)
            if components.count >= 2 {
                let name = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let description = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                stores.append(Store(name: name, description: description))
            }
        }
    } catch {
        print("讀取 \(fileName).csv 時出錯: \(error)")
    }
    
    return stores
}

/// 處理 CSV 行
func splitCSVLine(line: String) -> [String] {
    var result: [String] = []
    var current = ""
    var insideQuotes = false
    
    for char in line {
        if char == "\"" {
            insideQuotes.toggle()
        } else if char == "," && !insideQuotes {
            result.append(current)
            current = ""
        } else {
            current.append(char)
        }
    }
    result.append(current)
    return result
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
