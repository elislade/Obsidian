//
//  RootViewController.swift
//  Obsidian
//
//  Created by Eli Slade on 2019-10-10.
//  Copyright © 2019 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

protocol QuestAPIPresentable {
    func login()
    func logout()
}

class RootViewController: UIViewController {
    
    let THEME_CHANGE_THRESHOLD: TimeInterval = 10
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.system.statusBarStyle
    }
    
    lazy var loginController: LoginViewController = {
        let s = UIStoryboard(name: "Main", bundle: nil)
        return s.initVC(LoginViewController.self)
    }()
    
    lazy var tab: AppTabBarController = {
        return AppTabBarController()
    }()
    
    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    var shouldSkipLogin = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThemeManager.main.adjustTheme(to: UIScreen.main.brightness)
        Timer.scheduledTimer(withTimeInterval: THEME_CHANGE_THRESHOLD, repeats: true, block: { _ in
           ThemeManager.main.adjustTheme(to: UIScreen.main.brightness)
        })
        
        API.questAuth.delegate = self
        API.questAuth.authCtrlDelegate = self
        
        addChild(loginController)
        addChild(tab)
        view.addSubview(loginController.view)
        
        if ProcessInfo.processInfo.arguments.contains("UITesting") || shouldSkipLogin {
            API.quest.shouldUseMockResponse = true
            loginController.longPressRecognizer.minimumPressDuration = 0.2
            setupUser()
        } else {
            if API.questAuth.isAuthorized {
                checkLocalAuth()
            }
        }

    }
    
    func flip(from ctrl: UIViewController, to ctrl2: UIViewController){
        transition(
            from: ctrl,
            to: ctrl2,
            duration: 0.5,
            options: .transitionFlipFromLeft,
            animations: nil,
            completion: nil
        )
    }
    
    func login() {
        flip(from: loginController, to: tab)
    }

    func logout() {
        flip(from: tab, to: loginController)
    }
    
    func setupUser(animated: Bool = true) {
        API.quest.accounts { res in
            switch res {
            case .failure(_): break
            case .success(let actResponse):
                User.shared = User(actRes: actResponse)
                DispatchQueue.main.async {
                    self.login()
                }
            }
            self.hideActivityUI()
        }
    }
    
    func showActivityUI() {
        DispatchQueue.main.async {
            self.view.addSubview(self.activityIndicator)
            self.view.isUserInteractionEnabled = false
            self.activityIndicator.frame = self.view.bounds
            self.activityIndicator.center = self.view.center
            self.activityIndicator.startAnimating()
        }
    }
    
    func hideActivityUI() {
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = true
            self.activityIndicator.removeFromSuperview()
        }
    }
    
    func checkLocalAuth() {
        LocalAuth.main.authorize(reason:"Login") { error in
            if let _ = error {
                self.hideActivityUI()
            } else {
                self.setupUser()
            }
        }
    }
    
    func checkAPIAuthorization() {
        showActivityUI()
        
        if !API.questAuth.isAuthorized {
            API.questAuth.authorize { error in
                if let e = error as? iOSQuestAuthError {
                    if e == .authControllerWasDismissed {
                        self.hideActivityUI()
                    }
                } else {
                    self.setupUser()
                }
            }
        } else {
            checkLocalAuth()
        }
    }
}

extension RootViewController: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = theme.system.userInterfaceStyle
            setOverrideTraitCollection(UITraitCollection(userInterfaceStyle: theme.system.userInterfaceStyle), forChild: self)
        }
    }
}

extension RootViewController: QuestAuthDelegate {
    func didSignOut(_ questAuth: QuestAuth) {
        let alertTitle = NSLocalizedString("Questrade Did Revoke Access", comment: "")
        let alertMsg = NSLocalizedString("Please sign-in again!", comment: "")
        let alertAction = NSLocalizedString("Okay", comment: "")
        
        let alertCtrl = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: alertAction, style: .cancel, handler: { act in
            self.view.tintAdjustmentMode = .normal
            self.logout()
        }))
        
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.view.tintAdjustmentMode = .dimmed
            self.present(alertCtrl, animated: true, completion: nil)
        }
    }
}

extension RootViewController: QuestAPIDelegate {
    func didRecieveError(_ api: QuestAPI, error: Error) {
        let titleStr = NSLocalizedString("Error!", comment: "")
        let okayStr = NSLocalizedString("Okay", comment: "")
        let act = AlertController(title: titleStr, message: error.localizedDescription, preferredStyle: .alert)
        let okay = UIAlertAction(title: okayStr, style: .default, handler: nil)
        act.addAction(okay)
        
        DispatchQueue.main.async {
            self.topPresentedViewController.present(act, animated: true, completion: nil)
        }
    }
}

extension RootViewController: QuestAuthCtrlCustomizable {
    func willPrepareAuthCtrl(for customization: inout AuthViewControllerCustomization) {
        customization.preferredBarTintColor = theme.primaryBackgroundColor
        customization.preferredControlTintColor = theme.system.tintColor
    }
}
