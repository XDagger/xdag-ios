//
//  FirstViewController.swift
//  xdag-ios
//
//  Created by yangyin on 2018/2/25.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import UIKit
import SnapKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var hv:TransactionViewController = Util.GetViewController(controllerName: "transactionView")
        self.addChildViewController(hv)
        self.view.addSubview(hv.view)
        hv.view.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.view).offset(200)
            maker.leading.equalTo(self.view).offset(0)
            maker.trailing.equalTo(self.view).offset(0)
            maker.bottom.equalTo(self.view).offset(-49)

        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

