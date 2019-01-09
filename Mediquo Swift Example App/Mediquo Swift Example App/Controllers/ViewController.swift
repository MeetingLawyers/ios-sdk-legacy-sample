//
//  Copyright © 2017 Edgar Paz Moreno. All rights reserved.
//

import MediQuo

class ViewController: UIViewController {
    @IBOutlet weak var welcomeTitleLabel: UILabel!
    @IBOutlet weak var openChatButton: UIButton!

    private var isAuthenticated: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        prepareUI()
    }
git sty
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if var style = MediQuo.style {
            style.rootLeftBarButtonItem = buildFingerPrintButtonItem()
            MediQuo.style = style
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

    private func prepareUI() {
        setTexts()
        configureStyle()
    }
    
    private func setTexts() {
        self.welcomeTitleLabel.text = R.string.localizable.mainWelcomeText()
        self.openChatButton.setTitle(R.string.localizable.mainButtonText(), for: .normal)
    }
    
    private func configureStyle() {
        if var style = MediQuo.style {
            style.navigationBarColor = UIColor(red: 84 / 255, green: 24 / 255, blue: 172 / 255, alpha: 1)
            style.accentTintColor = UIColor(red: 0, green: 244 / 255, blue: 187 / 255, alpha: 1)
            style.preferredStatusBarStyle = .lightContent
            style.navigationBarTintColor = .white
            style.navigationBarOpaque = true
            style.titleColor = .white
            MediQuo.style = style
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
        MediQuo.unreadMessageCount {
            if let count = $0.value {
                UIApplication.shared.applicationIconBadgeNumber = count
                NSLog("[LaunchScreenViewController] Pending messages to read '\(count)'")
            }
        }
    }

    private func present() {
        MediQuo.present()
    }

    @objc private func authenticationState() {
        changeColorFingerPrintByAuthState()
        changeStatus()
    }
    
    private func changeColorFingerPrintByAuthState() {
        if let style = MediQuo.style, let buttonItem = style.rootLeftBarButtonItem {
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
        if let userToken: String = MediQuo.getUserToken() {
            MediQuo.authenticate(token: userToken) {
                let success = $0.isSuccess
                self.isAuthenticated = success
                if let completion = completion { completion(success) }
            }
        }
    }

    private func doLogout() {
        MediQuo.shutdown { _ in self.isAuthenticated = false }
    }
}
