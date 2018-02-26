//
//  GuideViewController.swift
//  xdag-ios
//
//  Created by yangyin on 2018/2/25.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import UIKit
import paper_onboarding
import SnapKit

class GuideViewController: UIViewController {

    var btnEnter:UIButton!
    static let titleFont = UIFont(name: "Nunito-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0)
    static let descriptionFont = UIFont(name: "OpenSans-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
    fileprivate let items = [
        OnboardingItemInfo(informationImage: UIImage(named: "guide-pc")!,
                           title: "Mineable",
                           description: "XDAG is both CPU & GPU mineable. Making it the first mineable dag project.",
                           pageIcon: UIImage(named: "guide-pc-mine")!,
                           color: UIColor(red: 105/255, green: 124/255, blue: 196/255, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        OnboardingItemInfo(informationImage:  UIImage(named: "guide-data")!,
                           title: "Privacy",
                           description: "Privacy in development: XDAG is working on incorporating privacy features. These are in active development and part of the 2018 roadmap",
                           pageIcon: UIImage(named: "guide-private-lock")!,
                           color: UIColor(red: 121/255, green: 153/255, blue: 190/255, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        OnboardingItemInfo(informationImage:  UIImage(named: "guide-code")!,
                           title: "Smart contracts",
                           description: "XDAG is actively developing smart contracts. Coming soon in 2018",
                           pageIcon: UIImage(named: "guide-link")!,
                           color: UIColor(red: 136/255, green: 178/255, blue: 184/255, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnEnter = UIButton()
        btnEnter.setTitle("enter XDAG wallet", for: UIControlState.normal)
        btnEnter.layer.borderColor = UIColor.white.cgColor
        btnEnter.layer.borderWidth = 1
        btnEnter.setTitleColor(UIColor.white, for: UIControlState.normal)
        btnEnter.addTarget(self, action: #selector(GuideViewController.btnEnterPressed(_:)), for: UIControlEvents.touchUpInside)
        btnEnter.isHidden = true
        
        setupPaperOnboardingView()
        view.addSubview(btnEnter)
        
        btnEnter.snp.makeConstraints { (make) in
            make.width.equalTo(180)
            make.height.equalTo(40)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-110)
        }

    }
    
    private func setupPaperOnboardingView() {
        let onboarding = PaperOnboarding()
        onboarding.delegate = self
        onboarding.dataSource = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        
        onboarding.snp.makeConstraints { (make) in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view)
            make.bottom.equalTo(self.view)

        }
        
    }
    
    @objc func btnEnterPressed(_ sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.view.window?.rootViewController = appDelegate.originViewController
        print("btnEnterPressed")
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

// MARK: PaperOnboardingDelegate

extension GuideViewController: PaperOnboardingDelegate {
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        btnEnter.isHidden = index == 2 ? false : true
    }
    
    func onboardingDidTransitonToIndex(_: Int) {
    }
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        
    }
}

// MARK: PaperOnboardingDataSource
extension GuideViewController: PaperOnboardingDataSource {
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return items[index]
    }
    
    func onboardingItemsCount() -> Int {
        return 3
    }
}

