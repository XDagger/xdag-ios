//
//  ReceiveViewController.swift
//  xdag-ios
//
//  Created by yangyin on 2018/2/25.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import UIKit

class ReceiveViewController: UIViewController {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressQRCode: UIImageView!
    var xdagAdress:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        xdagAdress = "4f1Sp/UD5533ddxxevUCpyenaPwqmpC"; // for testing
        setupViews(address: xdagAdress!)
        
    }
    
    func setupViews(address:String) {
        addressLabel.text = address
        
        var qrScheme = XDagQuerySerialization.encode(address: address, paramsDictionary: [:])
        addressQRCode.image = generateQRCodeImage(qrString: qrScheme)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func copyAddress(_ sender: Any) {
        UIPasteboard.general.string = addressLabel.text
        self.noticeSuccess("copy success!", autoClear: true,autoClearTime:1)

    }
    
    // generate QRCode
    private func generateQRCodeImage(qrString: String) -> UIImage? {
        let parameters: [String : Any] = [
            "inputMessage": qrString.data(using: .utf8)!,
            "inputCorrectionLevel": "L"
        ]
        let filter = CIFilter(name: "CIQRCodeGenerator", withInputParameters: parameters)
        
        guard let outputImage = filter?.outputImage else {
            return nil
        }
        
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 6, y: 6))
        guard let cgImage = CIContext().createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }


}

