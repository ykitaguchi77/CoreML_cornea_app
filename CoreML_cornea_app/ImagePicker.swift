//
//  ImagePicker.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/12/03.
//  https://tomato-develop.com/swiftui-how-to-use-camera-and-select-photos-from-library/
//
// movie acquision:
//https://hatsunem.hatenablog.com/entry/2018/12/04/004823
//https://off.tokyo/blog/how-to-access-info-plist/
//https://ichi.pro/swift-uiimagepickercontroller-250133769115456
//正方形動画撮影　https://superhahnah.com/swift-square-av-capture/
 
import SwiftUI
import UIKit
import AssetsLibrary
import Foundation
import AVKit
import Photos
import AVFoundation
 
struct Imagepicker : UIViewControllerRepresentable {
    @Binding var show:Bool
    @Binding var image:Data
    
    var sourceType:UIImagePickerController.SourceType
 
    func makeCoordinator() -> Imagepicker.Coodinator {
        
        return Imagepicker.Coordinator(parent: self)
    }
      
    func makeUIViewController(context: UIViewControllerRepresentableContext<Imagepicker>) -> UIImagePickerController {
        let controller = UIImagePickerController()
        if self.sourceType == .camera{
            controller.sourceType = sourceType
            controller.delegate = context.coordinator
            //photo, movieモード選択
            //controller.mediaTypes = ["public.image", "public.movie"]
            //controller.mediaTypes = ["public.image"]
            //controller.cameraCaptureMode = .video // Default media type .photo vs .video
            controller.videoQuality = .typeHigh
            controller.cameraFlashMode = .off
            controller.cameraDevice = .rear //or front
            controller.allowsEditing = false
            let screenWidth = UIScreen.main.bounds.size.width
            //overlay image
            //controller.cameraOverlayView = CircleView(frame: CGRect(x: (screenWidth / 2) - 50, y: (screenWidth / 2) + 25, width: 100, height: 100))
            controller.mediaTypes = ["public.image"]
            controller.cameraCaptureMode = .photo
            controller.cameraOverlayView = RectangleView(frame: CGRect(x: 0, y: screenWidth*0.28, width: screenWidth, height: screenWidth))
        }
        else if self.sourceType == .photoLibrary{
            controller.sourceType = sourceType
            controller.delegate = context.coordinator
            controller.mediaTypes = ["public.image"]
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<Imagepicker>) {
    }
    
    class Coodinator: NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
 
        var parent : Imagepicker
        
        init(parent : Imagepicker){
            self.parent = parent
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.show.toggle()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            // Check for the media type
            if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
 
                if mediaType  == "public.image" {
                    print("Image Selected")
                    
                    let image = info[.originalImage] as! UIImage
                    let data = image.pngData()
                    self.parent.image = data!
                    self.parent.show.toggle()
 
                    UIImageWriteToSavedPhotosAlbum(image, nil,nil,nil) //カメラロールに保存
 
                    let cgImage = image.cgImage //CGImageに変換
                    let cropped = cgImage!.cropToSquare()
                    //撮影した画像をresultHolderに格納する
                    let imageOrientation = getImageOrientation()
                    let rawImage = UIImage(cgImage: cropped).rotatedBy(orientation: imageOrientation)
                    ResultHolder.GetInstance().SetImage(index: 0, cgImage: rawImage.cgImage!)
                    //ResultHolder.GetInstance().SetMovieUrls(Url: "")
                    //setImage(progress: 0, cgImage: rawImage.cgImage!)
                }
            }
        }
        
        
 
        func saveMovieToPhotoLibrary(fileURL: URL) {
            //カメラロールに保存
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
            })
        }
 
        
        func saveToResultHolder(fileURL: URL){
            //ResultHolderに保存
            ResultHolder.GetInstance().SetMovieUrls(Url: fileURL.absoluteString)
        }
    }
}
 
 
//class CircleView: UIView {
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.backgroundColor = UIColor.clear
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func draw(_ rect: CGRect) {
//        if let context = UIGraphicsGetCurrentContext() {
//            context.setLineWidth(3.0)
//            UIColor.red.set()
//
//            let center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
//            let radius = (frame.size.width - 10) / 2
//
//            context.addArc(center: center, radius: radius, startAngle: 0.0, endAngle: .pi * 2.0, clockwise: true)
//            context.strokePath()
//        }
//    }
//}
 
 
class RectangleView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(3.0)
            UIColor.red.set()
            
            let width = frame.size.width
            
            context.addRect(CGRect(origin:CGPoint(x:0, y:0), size: CGSize(width:width, height:width)))
            
            //Elllipse
            UIColor.blue.set()
            context.addEllipse(in: CGRect(x:width*3/10, y:width*30/96, width:width*2/5, height:width*2/5))
            
            context.strokePath()
        }
    }
}
