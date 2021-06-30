//
//  Copyright © 2017 Edgar Paz Moreno. All rights reserved.
//

import MediQuo
import AdSupport
import MeetingLawyersSDK


class ViewController: UIViewController {
    @IBOutlet weak var welcomeTitleLabel: UILabel!
    @IBOutlet weak var openChatButton: UIButton!
    @IBOutlet weak var openChatMLButton: UIButton!
    
    private var isAuthenticated: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        prepareUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if var style = MDMediquo.style {
            style.rootLeftBarButtonItem = buildFingerPrintButtonItem()
            MDMediquo.style = style
        }
        
        if var style = MLMediQuo.style {
            style.rootLeftBarButtonItem = buildFingerPrintButtonItem()
            MLMediQuo.style = style
        }
    }

    @IBAction func openChatAction(_ sender: UIButton) {
        doLogin(completion: { isSuccess in
            if isSuccess {
                self.unreadMessageCount()
                self.present()
            }
        })
    }

    @IBAction func openMLChatAction(_ sender: Any) {
        doMLLogin(completion: { isSuccess in
            if isSuccess {
                self.unreadMLMessageCount()
                self.presentML()
            }
        })
    }
    
    private func prepareUI() {
        setTexts()
        configureStyle()
    }
    
    private func setTexts() {
        self.welcomeTitleLabel.text = R.string.localizable.mainWelcomeText()
        self.openChatButton.setTitle(R.string.localizable.mainButtonText(), for: .normal)
        self.openChatMLButton.setTitle(R.string.localizable.mainButtonMltext(), for: .normal)
    }
    
    private func configureStyle() {
        if var style = MDMediquo.style {
            style.navigationBarColor = UIColor(red: 84 / 255, green: 24 / 255, blue: 172 / 255, alpha: 1)
            style.accentTintColor = UIColor(red: 0, green: 244 / 255, blue: 187 / 255, alpha: 1)
            style.preferredStatusBarStyle = .lightContent
            style.navigationBarTintColor = .white
            style.navigationBarOpaque = true
            style.titleColor = .white
            MDMediquo.style = style
        }
        
        if var style = MLMediQuo.style {
            style.navigationBarColor = UIColor(red: 84 / 255, green: 24 / 255, blue: 172 / 255, alpha: 1)
            style.accentTintColor = UIColor(red: 0, green: 244 / 255, blue: 187 / 255, alpha: 1)
            style.preferredStatusBarStyle = .lightContent
            style.navigationBarTintColor = .white
            style.navigationBarOpaque = true
            style.titleColor = .white
            MLMediQuo.style = style
        }
    }

    private func buildFingerPrintButtonItem() -> UIBarButtonItem {
        let image = R.image.fingerprint()
        let style: UIBarButtonItem.Style = .plain
        let target = self
        let action = #selector(authenticationState)
        return UIBarButtonItem(image: image, style: style, target: target, action: action)
    }

    private func unreadMessageCount() {
        MDMediquo.unreadMessageCount {
            if let count = $0.value {
                UIApplication.shared.applicationIconBadgeNumber = count
                NSLog("[LaunchScreenViewController] Pending messages to read '\(count)'")
            }
        }
    }
    
    private func unreadMLMessageCount() {
        MLMediQuo.unreadMessageCount {
            if let count = $0.value {
                UIApplication.shared.applicationIconBadgeNumber = count
                NSLog("[LaunchScreenViewController] Pending messages to read '\(count)'")
            }
        }
    }

    private func present() {
        let messengerResult = MDMediquo.messengerViewController()
        if let controller: UINavigationController = messengerResult.value {
            self.present(controller, animated: true)
        } else {
            NSLog("[ViewController] Failed to instantiate messenger with error '\(String(describing: messengerResult.error))'")
        }
    }
    
    private func presentML() {
        let messengerResult = MLMediQuo.messengerViewController()
        if let controller: UINavigationController = messengerResult.value {
            self.present(controller, animated: true)
        } else {
            NSLog("[ViewController] Failed to instantiate messenger with error '\(String(describing: messengerResult.error))'")
        }
    }

    @objc private func authenticationState() {
        changeColorFingerPrintByAuthState()
        changeStatus()
    }
    
    private func changeColorFingerPrintByAuthState() {
        if let style = MDMediquo.style, let buttonItem = style.rootLeftBarButtonItem {
            buttonItem.tintColor = isAuthenticated ? .red : view.tintColor
        }
    }
    
    private func changeStatus() {
        if !isAuthenticated {
            doLogin()
        } else {
            doLogout()
        }
    }
    
    private func doLogin(completion: ((Bool) -> Void)? = nil) {
        let userToken: String = MDMediquo.getUserToken()
        MDMediquo.authenticate(token: userToken) {
            let success = $0.isSuccess
            self.isAuthenticated = success
            if let completion = completion { completion(success) }
        }
    }

    private func doLogout() {
        MDMediquo.shutdown { _ in self.isAuthenticated = false }
    }
    
    private func doMLLogin(completion: ((Bool) -> Void)? = nil) {
        let userToken: String = MLMediQuo.getUserToken()
        MLMediQuo.authenticate(token: userToken) {
            let success = $0.isSuccess
            self.isAuthenticated = success
            if let completion = completion { completion(success) }
        }
    }

    private func doMLLogout() {
        MLMediQuo.shutdown { _ in self.isAuthenticated = false }
    }
    
    func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else {
                assertionFailure("Not able to open App privacy settings")
                return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

