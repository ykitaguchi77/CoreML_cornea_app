//
//  ContentView.swift
//  CoreMLwithSwiftUI
//
//  Created by Moritz Philip Recke for Create with Swift on 24 May 2021.
//  https://github.com/create-with-swift/coreml-with-swiftui
//


import SwiftUI
import CoreML

class User : ObservableObject {
    @Published var sourceType: UIImagePickerController.SourceType = .camera //撮影モードがデフォルト
    }


struct ContentView: View {
    @ObservedObject var user = User()
    @State private var goTakePhoto: Bool = false  //撮影ボタン
    @State private var uploadData: Bool = false  //アップロードボタン

    
    //Define model
    //let model = MobileNetV2_pytorch()
    //let model = gravcont_MobileNet3()
    let model = gravcont_MobileNet3()

    
    //Define labels
    @State private var classificationLabel: String = ""
    @State private var rotate: Int = 0
    @State private var photos = ["GO", "degawa", "aragaki", "aragaki_2", "zuimakushu", "monalisa"]
    @State private var currentIndex: Int = 0
    
    
    var body: some View {
            GeometryReader {geometry in
                VStack(spacing: 0) {
                    Text("Classify app")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    if ResultHolder.GetInstance().GetUIImages() == []{
                        Image(photos[currentIndex], bundle: .main)
                            .resizable()
                            .frame(width: geometry.size.width*0.9, height: geometry.size.width*0.9)
                    }else{
                        GetImageStack(images: ResultHolder.GetInstance().GetUIImages(), shorterSide: GetShorterSide(screenSize: geometry.size))
                        
                    }
                    
                    HStack{
                        Button(action: {
                            self.user.sourceType = UIImagePickerController.SourceType.camera
                            self.goTakePhoto = true /*またはself.show.toggle() */
                        }) {
                            HStack{
                                Image(systemName: "camera")
                                Text("Take Photo")
                            }
                            .foregroundColor(Color.white)
                            .font(Font.largeTitle)
                        }
                        .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 50)
                        .background(Color.black)
                        .padding()
                        .sheet(isPresented: self.$goTakePhoto) {
                            CameraPage(user: user)
                        }
                        
                        Button(action: {
                            self.user.sourceType = UIImagePickerController.SourceType.photoLibrary
                            self.uploadData = true /*またはself.show.toggle() */
                            
                        }) {
                            HStack{
                                Image(systemName: "folder")
                                Text("Up")
                            }
                            .foregroundColor(Color.white)
                            .font(Font.largeTitle)
                        }
                        .frame(minWidth:0, maxWidth:200, minHeight: 50)
                        .background(Color.black)
                        .padding()
                        .sheet(isPresented: self.$uploadData) {
                            CameraPage(user: user)
                        }
                        
                    }
                    
                    HStack{
                        Button("Next") {
                            if self.currentIndex < self.photos.count - 1 {
                                self.currentIndex = self.currentIndex + 1
                            } else {
                                self.currentIndex = 0
                            }
                        }
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.gray)
                        
                        // The button we will use to classify the image using our model
                        Button("Classify") {
                            // Add more code here
                            classifyImage()
                        }
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.green)
                        
                        Button(action: {
                            if ResultHolder.GetInstance().GetUIImages() != []{
                                ResultHolder.GetInstance().SetImage(index: 0, cgImage: ResultHolder.GetInstance().GetUIImages()[0].rotatedBy(orientation: UIImage.Orientation.left).cgImage!)
                                print("rotated!")
                                countUp(rotate: rotate)
                            }
                        }
                        ) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(Color.white)
                                .font(Font.largeTitle)
                        }
                        .frame(minWidth:0, maxWidth:geometry.size.width*0.25, minHeight: 50)
                        .background(Color.black)
                        .padding()
                    }
                    
                    // The Text View that we will use to display the results of the classification
                    Text(classificationLabel)
                        .padding()
                        .font(.body)
                    Text("rotate: \(String(rotate))") //画像回転時の切り替え用
                    Spacer()
                }
                .frame (width: geometry.size.width)
        }
    }
    
    private func classifyImage() {
        let image: UIImage
        let currentImageName = photos[currentIndex]
        
        if ResultHolder.GetInstance().GetUIImages() == []{
            image = UIImage(named: currentImageName)!
        }else{
            image = ResultHolder.GetInstance().GetUIImages()[0]
        }
        
        guard let resizedImage = image.resizeImageTo(size:CGSize(width: 224, height: 224)),
              let buffer = resizedImage.convertToBuffer() else {
              return
        }
        
        //let output = try? model.prediction(input_1: buffer)
        let output = try? model.prediction(input_1: buffer)
        
        if let output = output {
            //let results = output.var_879.sorted { $0.1 > $1.1 } //modelにより名前が変わるので注意
            let results = output.var_879.sorted { $0.1 > $1.1 } //modelにより名前が変わるので注意
            let topThree = results[0...1]
            let result = topThree.map { (key, value) in
                return "\(key) = \(String(format: "%.2f", value * 100))%"
            }.joined(separator: "\n")

            self.classificationLabel = result
        }
    }
    
    private func countUp(rotate: Int){
        self.rotate += 1
    }
    
}
