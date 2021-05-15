//
//  LoginViewController.swift
//  Obsidian
//
//  Created by Eli Slade on 2017-08-17.
//  Copyright © 2017 Eli Slade. All rights reserved.
//

import UIKit
import QuestAPI

class LoginViewController: UIViewController {
    
    var shouldSkipLogin = false
    
    @IBOutlet weak var privacyPolicyTextView: UITextView!
    @IBOutlet weak var appLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet var longPressRecognizer: UILongPressGestureRecognizer!
    
    var rootCtrl: RootViewController? {
        parent as? RootViewController
    }
    
    @IBAction func signIn(_ sender: Any) {
        rootCtrl?.checkAPIAuthorization()
    }
    
    @IBAction func loginUsingMockData(_ sender: Any) {
        API.quest.shouldUseMockResponse = true
        rootCtrl?.setupUser(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        privacyPolicyTextView.delegate = self
        let attributedString = NSMutableAttributedString(attributedString: privacyPolicyTextView.attributedText)
        
        if let path = Bundle.main.path(forResource: "ObsidianPrivacyPolicy", ofType: "txt") {
            let found = attributedString.setAsLink(textToFind: "privacy policy", linkURL: path)
            if found {
                privacyPolicyTextView.attributedText = attributedString
            }
        }
    }
    
}

extension LoginViewController: Themeable {
    func themeDidUpdate(_ theme: Theme) {
        privacyPolicyTextView.textColor = theme.secondaryForegroundColor
        appLabel.textColor = theme.primaryForegroundColor
        descriptionLabel.textColor = theme.secondaryForegroundColor
        view.backgroundColor = theme.primaryBackgroundColor
        
        let image = theme == .light ? UIImage(named: "button_light") : UIImage(named: "button")
        continueButton.setBackgroundImage(image, for: .normal)
    }
}

extension LoginViewController: UITextViewDelegate {
    @objc func done() {
        self.dismiss(animated: true, completion: nil)
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if let textViewController = storyboard?.initVC(TextViewController.self) {
            let nav = UINavigationController(rootViewController: textViewController)
            nav.modalPresentationStyle = .custom
            nav.transitioningDelegate = self
            let titleStr = NSLocalizedString("Obsidian User Agreement", comment: "")
            textViewController.title = titleStr
            textViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))

            do {
                let data = try Data(contentsOf: NSURL(fileURLWithPath: URL.absoluteString) as URL, options: .mappedIfSafe)
                let s = String(data: data, encoding: String.Encoding.ascii)
                textViewController.viewData = s
            } catch _ {
            }
            present(nav, animated: true, completion:nil)
        }
        return false
    }
}

extension LoginViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let m = ModalPresentationController(presentedViewController: presented, presenting: presenting)
        m.shouldDismissOnContainerTap = true
        return m
    }
}
