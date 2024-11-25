//
//  ContentView.swift
//  WhatoEat
//  Version 2.0.1
//
//  Created by Ray Huang on 2024/11/17.
//
import SwiftUI

struct ContentView: View {
    @State private var stores: [Store] = []
    @State private var isTextVisible: [Bool] = []
    @State private var selectedIndex: Int = 1
    @State private var isRandomizing: Bool = false
    @State private var location: String = "宵夜街"
    @State private var isMapVisible: Bool = false

    var body: some View {
        HStack {
            // 左邊：卡片瀏覽區
            VStack {
                if stores.isEmpty {
                    Text("載入中...")
                        .font(.headline)
                        .padding()
                } else {
                    TabView(selection: $selectedIndex) {
                        ForEach(0..<stores.count, id: \.self) { index in
                            StoreCard(store: stores[index], isTextVisible: $isTextVisible[index])
                                .tag(index)
                                .frame(width: 300, height: 300)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .onChange(of: selectedIndex) {
                        handleInfiniteScrolling()
                    }
                }
            }
            .frame(maxWidth: .infinity)

            // 右邊：功能按鈕區
            VStack(spacing: 20) {
                // 切換地點按鈕
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

                // 隨機選擇卡片按鈕
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
                .disabled(isRandomizing)

                // 查看地圖按鈕
                Button(action: {
                    isMapVisible.toggle()
                }) {
                    Text("查看地圖")
                        .font(.headline)
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .sheet(isPresented: $isMapVisible) {
                    MapView(location: location, isMapVisible: $isMapVisible)
                }
            }
            .frame(maxWidth: 300)
        }
        .padding()
        .onAppear {
            self.stores = createInfiniteStores(from: loadStoresFromJSON(fileName: "supperStreet"))
            self.isTextVisible = Array(repeating: true, count: stores.count)
        }
    }

    // 處理無限滾動
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

    // 創建無限滾動數據
    private func createInfiniteStores(from originalStores: [Store]) -> [Store] {
        guard !originalStores.isEmpty else { return [] }
        var infiniteStores = originalStores
        infiniteStores.insert(originalStores.last!, at: 0)
        infiniteStores.append(originalStores.first!)
        return infiniteStores
    }

    // 隨機選擇卡片
    private func randomizeCard() {
        guard !stores.isEmpty else { return }
        isRandomizing = true

        let totalTime = Double.random(in: 10.0...15.0)
        let finalIndex = Int.random(in: 1..<(stores.count - 1))

        var elapsedTime: Double = 0
        var currentDelay: Double = 0.08
        let maxDelay: Double = 2.5

        // 隱藏所有卡片文字
        withAnimation {
            isTextVisible = Array(repeating: false, count: stores.count)
        }

        Timer.scheduledTimer(withTimeInterval: currentDelay, repeats: true) { timer in
            elapsedTime += currentDelay
            withAnimation(.easeInOut(duration: currentDelay)) {
                selectedIndex = (selectedIndex + 1) % (stores.count - 1) + 1
            }
            currentDelay = min(currentDelay * 1.10, maxDelay)

            if elapsedTime >= totalTime {
                timer.invalidate()
                withAnimation(.easeInOut(duration: currentDelay)) {
                    selectedIndex = finalIndex
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // 顯示選中卡片的文字
                    withAnimation(.easeInOut(duration: 1.0)) {
                        isTextVisible[finalIndex] = true
                    }
                }

                isRandomizing = false
            }
        }
    }

    // 切換地點並加載相應數據
    private func toggleLocation() {
        location = (location == "後門") ? "宵夜街" : "後門"
        let fileName = (location == "後門") ? "backDoor" : "supperStreet"
        stores = createInfiniteStores(from: loadStoresFromJSON(fileName: fileName))
        isTextVisible = Array(repeating: true, count: stores.count)
        selectedIndex = 1
    }
}



// 數據模型
struct Store: Identifiable, Decodable {
    let id = UUID()
    let name: String
    let description: String
    let filename: String
    let x: Double
    let y: Double
    let hours: [String: String]

    private enum CodingKeys: String, CodingKey {
        case name = "stores"
        case description
        case filename
        case x
        case y
        case hours
    }
}

// 加載 JSON 數據
func loadStoresFromJSON(fileName: String) -> [Store] {
    guard let filePath = Bundle.main.path(forResource: fileName, ofType: "json") else {
        print("無法找到 \(fileName).json 檔案")
        return []
    }
    
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
        let decoder = JSONDecoder()
        let jsonObjects = try decoder.decode([Store].self, from: data)
        return jsonObjects
    } catch {
        print("讀取 \(fileName).json 時出錯: \(error)")
        return []
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
