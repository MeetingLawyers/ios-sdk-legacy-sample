//
//  Copyright © 2017 Edgar Paz Moreno. All rights reserved.
//

import UIKit
import MediQuo

class ViewController: UIViewController {
    @IBOutlet weak var welcomeTitleLabel: UILabel!
    @IBOutlet weak var openChatButton: UIButton!

    public var isAuthenticated: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.prepareUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareUI() {
        self.welcomeTitleLabel.text = R.string.localizable.mainWelcomeText()
        self.openChatButton.setTitle(R.string.localizable.mainButtonText(), for: .normal)

        MediQuo.style?.navigationBarColor = UIColor(red: 84 / 255, green: 24 / 255, blue: 172 / 255, alpha: 1)
        MediQuo.style?.accentTintColor = UIColor(red: 0, green: 244 / 255, blue: 187 / 255, alpha: 1)
        MediQuo.style?.preferredStatusBarStyle = .lightContent
        MediQuo.style?.navigationBarTintColor = .white
        MediQuo.style?.navigationBarOpaque = true
        MediQuo.style?.titleColor = .white

        // MediQuo.style?.divider = MediQuoDivider<UIView>(view: UIView(frame: .zero))
        //    .add(configuration: { (cell, view) in
        //        view.backgroundColor = UIColor(red: 84 / 255, green: 24 / 255, blue: 172 / 255, alpha: 0.7)
        //    })
        //    .add(selector: { (speciality, authorized) -> Bool in
        //        NSLog("[ViewController] Professional '\(String(describing: speciality))' selected and authorized '\(authorized)'")
        //        return true
        //    })
    }

    @IBAction func openChatAction(_ sender: UIButton) {
        let topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        let isSame = topController == self
        print(isSame)

        let userInfo: [String: Any] = Bundle.main.infoDictionary!
        MediQuo.authenticate(token: userInfo["MediQuoUserToken"] as! String) { [weak self] (result: MediQuo.Result<Void>) in
            self?.isAuthenticated = result.isSuccess
            self?.unreadMessageCount(result)
            self?.present(result)
        }
    }

    func present(_ completion: MediQuo.Result<Void>) {
        guard completion.isSuccess else { return }
        MediQuo.style?.rootLeftBarButtonItem = UIBarButtonItem(image: R.image.fingerprint(), style: .plain, target: self, action: #selector(ViewController.authenticationState))
        MediQuo.present()
    }
    
    func unreadMessageCount(_ completion: MediQuo.Result<Void>) {
        guard completion.isSuccess else { return }
        MediQuo.unreadMessageCount { (result: MediQuo.Result<Int>) in
            if let count = result.value {
                NSLog("[LaunchScreenViewController] Pending messages to read '\(count)'")
                UIApplication.shared.applicationIconBadgeNumber = count
            }
        }
    }

    @objc func authenticationState() {
        if self.isAuthenticated {
            MediQuo.style?.rootLeftBarButtonItem?.tintColor = .red
            self.isAuthenticated = false
            MediQuo.shutdown()
        } else {
            let userInfo: [String: Any] = Bundle.main.infoDictionary!
            MediQuo.style?.rootLeftBarButtonItem?.tintColor = self.view.tintColor
            MediQuo.authenticate(token: userInfo["MediQuoUserToken"] as! String) { [weak self] (result: MediQuo.Result<Void>) in
                self?.isAuthenticated = result.isSuccess
            }
        }
    }
}
