//
//  Copyright © 2017 Edgar Paz Moreno. All rights reserved.
//

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
        self.openChatMLButton.setTitle(R.string.localizable.mainButtonMltext(), for: .normal)
    }
    
    private func configureStyle() {
        
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
    
    private func unreadMLMessageCount() {
        MLMediQuo.unreadMessageCount {
            if let count = $0.value {
                UIApplication.shared.applicationIconBadgeNumber = count
                NSLog("[LaunchScreenViewController] Pending messages to read '\(count)'")
            }
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

