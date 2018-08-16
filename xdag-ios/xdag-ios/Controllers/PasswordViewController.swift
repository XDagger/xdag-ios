//
//  PasswordViewController.swift
//  xdag-ios
//
//  Created by yangyin on 2018/8/16.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController {

    @IBOutlet weak var passwordStack: UIStackView!
    let kPasswordDigit = 6

    var passwordContainerView: PasswordContainerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        
        //create PasswordContainerView
        passwordContainerView = PasswordContainerView.create(in: passwordStack, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        passwordContainerView.deleteButtonLocalizedTitle = "DELETE"
//        passwordContainerView.isTouchAuthenticationAvailable = true
//        passwordContainerView.is
        //customize password UI
        passwordContainerView.tintColor = UIColor.darkText
        passwordContainerView.highlightedColor = UIColor.navigationBarColor()
        
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
        if validation(input) {
            validationSuccess()
        } else {
            validationFail()
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
        return input == "123456"
    }
    
    func validationSuccess() {
        print("*️⃣ success!")
        dismiss(animated: true, completion: nil)
    }
    
    func validationFail() {
        print("*️⃣ failure!")
        passwordContainerView.wrongPassword()
    }
}
