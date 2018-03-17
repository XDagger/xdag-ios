//
//  AVCaptureSessionManager.swift
//  xdag-ios
//
//  Created by yangyin on 2018/3/11.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

typealias SuccessCallback = (String?) -> Void


class AVCaptureSessionManager: AVCaptureSession {
    
    private lazy var device: AVCaptureDevice? = {
        return AVCaptureDevice.default(for:.video)
    }()
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        return AVCaptureVideoPreviewLayer(session: self)
    }()
    
    private var successCallback:SuccessCallback?
    
    convenience init(captureType: AVCaptureType, scanRect: CGRect, success: @escaping SuccessCallback) {
        self.init()
        successCallback = success
        do
        {
            let input = try AVCaptureDeviceInput(device: device!)
            let output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            if !scanRect.equalTo(CGRect.null) {
                output.rectOfInterest = scanRect
            }
            
            sessionPreset = AVCaptureSession.Preset.high
            
            if canAddInput(input) {
                addInput(input)
            }
            
            if canAddOutput(output) {
                addOutput(output)
            }
            
            output.metadataObjectTypes = captureType.supportTypes()

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(stop),
                                                   name: NSNotification.Name.UIApplicationDidEnterBackground,
                                                   object: nil)
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(start),
                                                   name:NSNotification.Name.UIApplicationWillEnterForeground,
                                                   object: nil)
            
        }
        catch {
            print(error)
            return;
        }
    }
    
    /// startRunning
    @objc func start() {
        startRunning()
    }
    
    /// stopRunning
    @objc func stop() {
        stopRunning()
    }
    
    func scanPhoto(image: UIImage, success: SuccessCallback) {
        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                  context: nil,
                                  options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
        if detector != nil {
            let features = detector!.features(in: CIImage(cgImage: image.cgImage!))
            for temp in features {
                let result = (temp as! CIQRCodeFeature).messageString
                success(result)
                return
            }
            success(nil)
        }else {
            success(nil)
        }
        
    }
    
    func setPreviewLayerIn(view :UIView) {
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        start()
    }
    
    func turnTorch(state:Bool) {
        if let device = device {
            if (device.hasTorch) {
                do {
                    try device.lockForConfiguration()
                } catch let error as NSError {
                    print("TorchError  \(error)")
                }
                if (state) {
                    device.torchMode = AVCaptureDevice.TorchMode.on
                } else {
                    device.torchMode = AVCaptureDevice.TorchMode.off
                }
                device.unlockForConfiguration()
            }
        }
    }
}


extension AVCaptureSessionManager: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if (metadataObjects.count > 0) {
            stop()
            let result = metadataObjects.last as! AVMetadataMachineReadableCodeObject
            successCallback!(result.stringValue)
        }
    }
}

public protocol ScanXDagQRCodeResultDelegate : NSObjectProtocol {

    func scanSuccess(_ address:String, withParams params: [String:String]?)
}


enum AVCaptureType {
    case AVCaptureTypeQRCode
    case AVCaptureTypeBarCode
    case AVCaptureTypeBoth
    func supportTypes() -> [AVMetadataObject.ObjectType] {
        switch self {
        case .AVCaptureTypeQRCode:
            return [AVMetadataObject.ObjectType.qr]
        case .AVCaptureTypeBarCode:
            return [AVMetadataObject.ObjectType.dataMatrix,
                    AVMetadataObject.ObjectType.itf14,
                    AVMetadataObject.ObjectType.interleaved2of5,
                    AVMetadataObject.ObjectType.aztec,
                    AVMetadataObject.ObjectType.pdf417,
                    AVMetadataObject.ObjectType.code128,
                    AVMetadataObject.ObjectType.code93,
                    AVMetadataObject.ObjectType.ean8,
                    AVMetadataObject.ObjectType.ean13,
                    AVMetadataObject.ObjectType.code39Mod43,
                    AVMetadataObject.ObjectType.code39,
                    AVMetadataObject.ObjectType.upce]
        case .AVCaptureTypeBoth:
            return [AVMetadataObject.ObjectType.qr,
                    AVMetadataObject.ObjectType.dataMatrix,
                    AVMetadataObject.ObjectType.itf14,
                    AVMetadataObject.ObjectType.interleaved2of5,
                    AVMetadataObject.ObjectType.aztec,
                    AVMetadataObject.ObjectType.pdf417,
                    AVMetadataObject.ObjectType.code128,
                    AVMetadataObject.ObjectType.code93,
                    AVMetadataObject.ObjectType.ean8,
                    AVMetadataObject.ObjectType.ean13,
                    AVMetadataObject.ObjectType.code39Mod43,
                    AVMetadataObject.ObjectType.code39,
                    AVMetadataObject.ObjectType.upce]
        }
    }
}
