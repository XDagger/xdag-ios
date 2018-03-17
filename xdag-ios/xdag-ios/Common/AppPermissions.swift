//
//  AppPermissions.swift
//  xdag-ios
//
//  Created by yangyin on 2018/3/11.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import AssetsLibrary

class AppPermissions: NSObject {
    
    static func authorizePhotoWith(completion:@escaping (Bool)->Void )
    {
        let granted = PHPhotoLibrary.authorizationStatus()
        switch granted {
        case PHAuthorizationStatus.authorized:
            completion(true)
        case PHAuthorizationStatus.denied,PHAuthorizationStatus.restricted:
            completion(false)
        case PHAuthorizationStatus.notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async {
                    completion(status == PHAuthorizationStatus.authorized ? true:false)
                }
            })
        }
    }
    
    static func authorizeCameraWith(completion:@escaping (Bool)->Void )
    {
        let granted = AVCaptureDevice.authorizationStatus(for: AVMediaType.video);
        
        switch granted {
        case .authorized:
            completion(true)
            break;
        case .denied:
            completion(false)
            break;
        case .restricted:
            completion(false)
            break;
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted:Bool) in
                DispatchQueue.main.async {
                    completion(granted)
                }
            })
        }
    }
    
    static func jumpToSystemSetting()
    {
        let appSetting = URL(string:UIApplicationOpenSettingsURLString)
        
        if appSetting != nil
        {
            if #available(iOS 10, *) {
                UIApplication.shared.open(appSetting!, options: [:], completionHandler: nil)
            }
            else{
                UIApplication.shared.openURL(appSetting!)
            }
        }
    }
    
}
