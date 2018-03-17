//
//  ScanViewController.swift
//  xdag-ios
//
//  Created by yangyin on 2018/3/17.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import UIKit

class ScanViewController: UIViewController {

    var sessionManager:AVCaptureSessionManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sessionManager = AVCaptureSessionManager(captureType: .AVCaptureTypeQRCode, scanRect: CGRect.null, success: { (result) in
            if let strs = result {
                print(strs)
            }
        })
        
        sessionManager?.setPreviewLayerIn(view: view)
        
        let item = UIBarButtonItem(title: "Photos", style: .plain, target: self, action: #selector(pickPhoto))
        navigationItem.rightBarButtonItem = item
    }

    override func viewWillAppear(_ animated: Bool) {
        sessionManager?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionManager?.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func pickPhoto() {
        AppPermissions.authorizePhotoWith { (authorized) in
            if authorized {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    AppPermissions.jumpToSystemSetting()
                })
                let ac = UIAlertController(title:"Photos access", message: "Photos access was denied: open the settings app to change privacy settings", preferredStyle: UIAlertControllerStyle.alert)
                ac.addAction(action)
                self.present(ac, animated: true, completion: nil)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ScanViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        sessionManager?.start()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true) {
            self.sessionManager?.start()
            self.sessionManager?.scanPhoto(image: info["UIImagePickerControllerOriginalImage"] as! UIImage, success: { (result) in
                if let strs = result {
                    print("qrcode: \(strs)")
                }
            })
        }
    }
    
    
}
