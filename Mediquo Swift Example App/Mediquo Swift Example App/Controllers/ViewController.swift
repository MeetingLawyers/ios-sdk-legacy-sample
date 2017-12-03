//
//  Copyright © 2017 Edgar Paz Moreno. All rights reserved.
//

import UIKit
import MediQuo

class ViewController: UIViewController {
    @IBOutlet weak var welcomeTitleLabel: UILabel!
    @IBOutlet weak var openChatButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        prepareUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareUI() {
        welcomeTitleLabel.text = R.string.localizable.mainWelcomeText()
        openChatButton.setTitle(R.string.localizable.mainButtonText(), for: .normal)
        
    }

    @IBAction func openChatAction(_ sender: UIButton) {
        let topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        let isSame = topController == self
        print(isSame)

        let userInfo: [String: Any] = Bundle.main.infoDictionary!
        MediQuo.authenticate(token: userInfo["MediQuoUserToken"] as! String) { [weak self] (result: MediQuo.Result<Void>) in
            self?.unreadMessageCount(result)
            self?.present(result)
        }
    }
    
    func present(_ completion: MediQuo.Result<Void>) {
        guard completion.isSuccess else { return }
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
}
