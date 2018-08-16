//
//  PasswordViewController.swift
//  xdag-ios
//
//  Created by yangyin on 2018/8/16.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController {

    @IBOutlet weak var passwordTitle: UILabel!
    
    
    @IBOutlet weak var passwordSubtitle: UILabel!
    var firstSetPassword:Bool = false
    
    var newPassword:String = ""
    var xdagPassword:String = ""
    
    var homeViewController:HomeViewController?
    
    @IBOutlet weak var passwordStack: UIStackView!
    let kPasswordDigit = 6

    var passwordContainerView: PasswordContainerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        firstSetPassword = true

        //check password in keychain
        if KeychainWrapper.hasValueForKey("xdag-password") {
            firstSetPassword = false
            xdagPassword = KeychainWrapper.stringForKey("xdag-password")!
        }
        
        self.passwordSubtitle.isHidden = true;

        
        if(firstSetPassword) {
            self.passwordTitle.text  = "Create a password for XDAG"
            self.passwordSubtitle.isHidden = false;
        }
        
        //create PasswordContainerView
        passwordContainerView = PasswordContainerView.create(in: passwordStack, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        passwordContainerView.deleteButtonLocalizedTitle = "DELETE"
//        passwordContainerView.isTouchAuthenticationAvailable = true
//        passwordContainerView.is
        //customize password UI
        passwordContainerView.tintColor = UIColor.darkText
        passwordContainerView.highlightedColor = UIColor.navigationBarColor()
        if(firstSetPassword) {
            passwordContainerView.touchAuthenticationEnabled = false
        } else {
            passwordContainerView.touchAuthenticationEnabled = true

        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension PasswordViewController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        if(firstSetPassword) {
            if(newPassword == "") {
                //create NewPassword
                newPassword = input
                passwordContainerView.clearInput()
                self.passwordTitle.text  = "Re-enter password"
                self.passwordSubtitle.text = "password will be used to unlock and sent XDAG"
                return;
            }
            
            if(newPassword != input) {
//                print("*️⃣ failure!")
                passwordContainerView.wrongPassword()
                return;
            }
            KeychainWrapper.setString(newPassword, forKey: "xdag-password")
            self.validationSuccess()

        } else {
            if validation(input) {
                validationSuccess()
            } else {
                validationFail()
            }
        }
       
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            self.validationSuccess()
        } else {
            passwordContainerView.clearInput()
        }
    }
}

private extension PasswordViewController {
    func validation(_ input: String) -> Bool {
        return input == self.xdagPassword
    }
    
    func validationSuccess() {
//        print("*️⃣ success!")
        homeViewController?.loadXDagWallet();
        dismiss(animated: true, completion: nil)
    }
    
    func validationFail() {
//        print("*️⃣ failure!")
        passwordContainerView.wrongPassword()
    }
}
