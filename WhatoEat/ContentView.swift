import SwiftUI

struct ContentView: View {
    @State private var stores: [Store] = []
    @State private var isTextVisible: [Bool] = []
    @State private var selectedIndex: Int = 1
    @State private var isRandomizing: Bool = false
    @State private var location: String = "宵夜街"

    var body: some View {
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
            self.stores = createInfiniteStores(from: loadStoresFromJSON(fileName: "supperStreet"))
            self.isTextVisible = Array(repeating: true, count: stores.count)
        }
    }


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


    private func createInfiniteStores(from originalStores: [Store]) -> [Store] {
        guard !originalStores.isEmpty else { return [] }
        var infiniteStores = originalStores
        infiniteStores.insert(originalStores.last!, at: 0)
        infiniteStores.append(originalStores.first!)
        return infiniteStores
    }


    private func randomizeCard() {
        guard !stores.isEmpty else { return }
        isRandomizing = true

        let totalTime = Double.random(in: 10.0...15.0)
        let finalIndex = Int.random(in: 1..<(stores.count - 1))

        var elapsedTime: Double = 0
        var currentDelay: Double = 0.08
        let maxDelay: Double = 2.5


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
                    withAnimation(.easeInOut(duration: 1.0)) {
                        for index in stores.indices {
                            isTextVisible[index] = true
                        }
                    }
                }

                isRandomizing = false
            }
        }
    }


    private func toggleLocation() {
        location = (location == "後門") ? "宵夜街" : "後門"
        let fileName = (location == "後門") ? "backDoor" : "supperStreet"
        stores = createInfiniteStores(from: loadStoresFromJSON(fileName: fileName))
        isTextVisible = Array(repeating: true, count: stores.count)
        selectedIndex = 1
    }
}

struct StoreCard: View {
    let store: Store
    @Binding var isTextVisible: Bool
    @State private var isFlipped: Bool = false

    var body: some View {
        ZStack {
            VStack {
                if !isFlipped {
                    Text(store.name)
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding()
                        .opacity(isTextVisible ? 1 : 0)
                }
            }
            .frame(width: 300, height: 300)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .opacity(isFlipped ? 0 : 1)
            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))

            VStack {
                if isFlipped {
                    Text(store.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .frame(width: 300, height: 300)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .opacity(isFlipped ? 1 : 0)
            .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.8)) {
                isFlipped.toggle()
            }
        }
    }
}

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
