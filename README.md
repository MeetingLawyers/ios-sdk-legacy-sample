[![Language](https://img.shields.io/badge/Swift-4.2-orange.svg)](https://swift.org/)
[![Bintray](https://api.bintray.com/packages/mediquo/generic/MediQuo/images/download.svg)](https://bintray.com/mediquo/generic/MediQuo/_latestVersion)
[![BuddyBuild](https://dashboard.buddybuild.com/api/statusImage?appID=5a2464d0c5dd1600018b73bd&branch=master&build=latest)](https://dashboard.buddybuild.com/apps/5a2464d0c5dd1600018b73bd/build/latest?branch=master)
# Mediquo SDK

Here are the steps to follow to include the MediQuo library to an iOS application project.

## Requirements

| **Swift** | **Xcode** |   **MediQuo**  | **iOS** |
|-----------|-----------|----------------|---------|
| 4.0       | 9.0...9.2 | 0.1 ... 0.24.x | 10.0+   |
| 4.1       | 9.3...9.4 | 0.25.x         | 10.0+   |
| 4.2       | 9.4...11 | 0.33.x ... 0.35.x | 11.0+   |

Last version 0.35.44

## Instalation

To install the MediQuo library you must first include MediQuo private pods repository to the Cocoapods list using the following command:

```
pod repo add mediquo https://gitlab.com/mediquo/specs.git
```

Later, in the project 'Podfile' we have to add in the header the new pods origin, in addition to the default header of Cocoapods:

```ruby
source 'https://gitlab.com/mediquo/specs.git'
source 'https://github.com/CocoaPods/Specs.git'
```

And finally, we include the pod in the target of the project with the latest version:

```ruby
pod 'MediQuo'
```

## Access permissions

Access to camera or photo gallery always requires explicit permission from the user.

Your app must provide an explanation for its use of capture devices using the **NSCameraUsageDescription** and **NSPhotoLibraryUsageDescription** Info.plist key. iOS displays this explanation when initially asking the user for permission to attach an element in the current conversation. 

⚠️ Attempting to attach a gallery photo or start a camera session without an usage description will raise an exception.

## Integration

To use the library is necessary to import it in our AppDelegate:

```swift
import MediQuo
```

Next, as soon as we receive a notification from the system telling that our application is already active, we must configure the framework by providing the client's API key configuration:

```swift
class func initialize(_ application: UIApplication = UIApplication.shared, with configuration: MediQuo.Configuration, options _: [UIApplication.LaunchOptionsKey: Any]?, completion: ((MediQuo.Result<MediQuoInstallationType>) -> Void)? = nil) -> UUID?
```

Last method parameter defines asynchronous initialization result of type `MediQuoInstallationType`. It does return framework and installation information responding to the protocol:

```swift
public protocol MediQuoInstallationType {
    /// Unique intallation identifier for this device
    var installationId: UUID { get }
    /// UIDevice.current.systemVersion
    var systemVersion: String { get }
    /// MediQuo Framework build version number
    var frameworkVersion: String { get }
    /// Device manufacturer name (i.e. x86_64, iPhone8,2, etc.)
    var deviceModel: String { get }
    /// Installation referrer
    var referrer: MediQuoReferrerType? { get }
}
```

To initialize MediQuo SDK, you need to create a configuration object:

```swift
public struct Configuration {
    // Application name
    public let id: String
    // Chat Api key
    public let secret: String
    // If is `true`, SDK will be comunicate with sandbox environment. Otherwise interact with Production environment. By default es `false`
    public let isDemo: Bool
    // videocall apiKey, if is nil, videocall feature is disabled.
    public let videoCallApiKey: String?
    // call sound for videocall screen when professional is calling. File name must be the same for call notification.
    public let videCallSoundFileName: String?
}
```


Initialization returns an optional (`@discardableResult`) synchronous installation identifier that will only be valid after `initialize` call has succeeded once:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    [...]
    if let clientName: String = “client_name”,
        let clientSecret: String = “api_key” {
        let configuration = MediQuo.Configuration(id: clientName, secret: clientSecret)
        if let uuid: UUID = MediQuo.initialize(with: configuration, options: launchOptions) {
            NSLog("[MediQuoApplicationPlugin] Synchronous installation identifier: '\(uuid.uuidString)'")
        }
    }
    [...]
}
```

Without the initialization process, subsequent calls to the library will trigger error results.

## Authentication

Authentication verifies that the provided user token is correct and, therefore, it can initiate the chat.

```swift
MediQuo.authenticate(token: "token") { (result: MediQuo.Result<Void>) in
        switch result {
        case .success:
        [...]
        case .failure(let error):
        [...]
        }
}
```

The result of the authentication does not return any value beyond the same verification of success or failure of the operation.

From a successful response, we can consider that the user is authenticated and MediQuo environment is ready to show the active conversations of the user.

In the case of this example project you can find this snippet in class *ViewController*.

## Pending messages

Once the authentication process is over, we can then request the pending messages to be read by the user using the following method:

```swift
func unreadMessageCount(_ completion: @escaping (MediQuo.Result<Int>) -> Void)
```

So, once we get the result, we can update application badge icon:

```swift
MediQuo.unreadMessageCount { (result: MediQuo.Result<Int>) in
    if let count = result.value {
        UIApplication.shared.applicationIconBadgeNumber = count
    }
}
```

## Messenger view controller

Once we initialized the SDK and authenticated the user, we can retrieve the MediQuo UI using the following method:

```swift
public class func messengerViewController(with filter: MediQuoFilterType = 
    MediQuoFilter.default, showHeader: Bool = false, showDivider: Bool = true,
    onUpdateLayout listener: ((CGSize) -> Void)? = nil) ->
    MediQuo.Result<UINavigationController>
```

Method parameters have been overloaded with default values. So we can invoke the list of doctors by adding the following call:

```swift
[...]
let result = MediQuo.messengerViewController()
if let wrapController = result.value {
// do some stuff
}
[...]
```

### Filtered contact list

In order to filter the list of contacts, we must use the previous function passing a MediQuoFilter:

```swift
MediQuo.messengerViewController(with: MediQuoFilterType, onUpdateLayout: ((CGSize) -> Void)?)
```

It takes as a parameter the filters wanted to be applied and optionally a size in case we need to update a height constraint to fit the result list.

The next included example shows how we could filter the list using two specialities and taking the top two elements of the filtered elements:

```swift
let filter: MediQuoFilterType = MediQuoFilter(profiles: [.customerCare, .commercial], take: 2)
let result: MediQuo.Result<UINavigationController> = MediQuo.messengerViewController(with: filter) { (contentSize: CGSize) in
    // do some stuff to resize layout
}

if let controller: UITableViewController = result.value?.viewControllers.first as? UITableViewController {
    // Update the view with the controller
}
```

## Styles

MediQuo UI styles can be customized by creating an instance that complies with the 'MediQuoStyleType' protocol, modifying its properties and then linking it to the 'style' property of the library.

By default, the 'style' property is already configured with initial values that fit with the MediQuo brand and are used if the style value is not overwritten or simply initialized to nil.

### Properties:

```swift
// Font to use for the inbox title.
titleFont: UIFont? 

// Color of the navigation title. This includes inbox doctor list and professional name inside a conversation.
titleColor: UIColor? 

// A custom view displayed in the center of the navigation bar.
titleView: UIView? 

// Status bar style
preferredStatusBarStyle: UIStatusBarStyle

// Whether the navigation bar should be translucent.
navigationBarOpaque: Bool 

// Background color of the navigation bar
navigationBarColor: UIColor?

// Tint color of the navigation bar items, if applicable. This includes ‘back’ and ‘leftBarButtonItem’
navigationBarTintColor: UIColor? 

// Override navigation bar back button with provided image.
navigationBarBackIndicatorImage: UIImage?

// Title of the inbox navigation bar
inboxTitle: String?

// Left bar button item to use as child navigation item. It can be customized to put a button that invokes the MediQuo.dismiss() method or open a side menu. By default it is empty.
rootLeftBarButtonItem: UIBarButtonItem?

// Inbox cell style for contact list
inboxCellStyle: MediQuoInboxCellStyle

// Tint color for action controls.
accentTintColor: UIColor?

// Outgoing conversation messages text color
messageTextOutgoingColor: UIColor?

// Incoming conversation messages text color
messageTextIncomingColor: UIColor?

// Outgoing conversation messages bubble background color
bubbleBackgroundOutgoingColor: UIColor?

// Incoming conversation messages bubble background color
bubbleBackgroundIncomingColor: UIColor?

// Inbox contact list divider behavior.
divider: MediQuoDividerType?

// Secondary color for views. If not informed has same color as navigationBarColor
secondaryTintColor: UIColor?

// If is true show default background image of mediquo in the views.
showMediQuoBackgroundImage: Bool?

// Inbox contact list Header
topDivider: MediQuoDividerType?

// View used as background in chat screen.
chatBackgroundView: UIView?
```

### Divider configuration
Using `MediQuoDivider` generic builder we can configure a divider view group style and behavior.

Take for instance a `DividerContentView` which is a custom view we want to inject inside a divider cell. We would configure a style divider like this:

```swift
MediQuo.style?.divider = MediQuoDivider<DividerContentView>(view: divider)
    .add(configuration: { (cell, view) -> Void in
        view.button.setTitle("I'm interested", for: .normal)
        view.label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    })
    .add(selector: { (speciality, authorized) -> Bool in
        NSLog("[LaunchScreenViewController] Inbox item '\(String(describing: speciality))' selected and authorized '\(authorized)'")
        return true
    })
```

Configuration closure will be called every time the divider cell appears in the list so the user can update view values.

Selector will be called on every user interaction over the cell (i.e. did select row). If user is allowed to talk with the professional, return value can override chat access.

Both values are optional and it is not mandatory to implement them.

### Header configuration
Using `MediQuoDividerType` builder you can configure view for header inside doctor list. With `MediQuoDividerType` you can configure the view for header and the size for this view. If the frame width is higher than screen width, the header width will be same as screen widt. Example:

````swift
MediQuo.style?.topDivider = MediQuoDivider<TopDividerContentView>(view: inviteBanner())
````

If you want to remove the header you must set de headerView as `nil`.

### Inbox cell style configuration
Using `MediQuoInboxCellStyle` builder you can configure doctor list look. You can configure:
- `Overlay` color for unauthorized cells.
- `Badge` color for pending messages for a conversation.
- `Speciality`color for speciality color text.
Also you can choose cell style and can select `mediQuo` cell style or `classic` mediquo cell

Usage for `mediquo` cell:
```swift
MediQuo.style?.inboxCellStyle = .mediquo(overlay: .white, badge: .cyan, specyality: .magenta)
```

Usage for `classic` cell:
```swift
MediQuo.style?.inboxCellStyle = .classic(overlay: .white, badge: .cyan, specyality: .magenta)
```

## Referrer
You can retrieve installation referral code from MediQuo library, and know if the user accessed the app with an invitation code. Referral code can be obtained through mediQuo class property or on framework initialization result type.

Usage:

```swift
let code: String = MediQuo.referrer
```

## Shutdown

A `shutdown` method exists so a chat user can disconnect and erase all sensible information:

```swift
MediQuo.shutdown { (result: MediQuo.Result<Void>) in
        switch result {
        case .success:
        [...]
        case .failure(let error):
        [...]
        }
}
```

This operation removes all user concerning information, so once a user is deauthenticated, a call to `authenticate` must be invoked to access the contact list again.

## Push notifications

MediQuo framework uses push notifications to communicate users' pending messages.

As soon as the on-screen chat presentation starts, if permissions to send notifications have not yet been needed by the host application, the system security dialog is displayed. When the user grants the necessary permissions to send push notifications, it is mandatory to intervene system remote notification calls to notify MediQuo with the new device token. To do so, we require to implement the following methods in your AppDelegate:

```swift
func application(_ application: UIApplication, 
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        MediQuo.didRegisterForRemoteNotifications(with: deviceToken)
}

func application(_ application: UIApplication, 
    didFailToRegisterForRemoteNotificationsWithError error: Error) {
        MediQuo.didFailToRegisterForRemoteNotifications(with: error)
}

func application(_ application: UIApplication, 
    didReceiveRemoteNotification userInfo: [AnyHashable : Any], 
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        MediQuo.didReceiveRemoteNotification(application, with: userInfo) { (result: MediQuo.Result<UIBackgroundFetchResult>) in
            do {
                completionHandler(try result.unwrap())
            } catch {
                completionHandler(.failed)
            }
        }
}
```

⚠️ WARNING:

> It is necessary that the host application has the necessary permissions and entitlements to receive push notifications.

> It is essential to provide an Authorization key to the administrator of your MediQuo account so that notifications are received correctly.

> It is highly recommended to implement background fetch result and modify your app capabilities to include 'fetch' and 'remote-notification' entitlements.

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

## Videocall

- To enable videocall feature, first, you must configure videocallApiKey in the configuration structure before initialize SDk as mentioned in [Integration](#Integration).

- Next you need to configure push to hear videocall push noticiation to update videocall status:

````swift
        MediQuo.userNotificationCenter(userNotificationCenter, didReceive: response) { result in
            result.process(doSuccess: { _ in
                completionHandler()
            }, doFailure: { error in
                if let mediQuoError = error as? MediQuoError,
                    case let .videoCall(reason) = mediQuoError,
                    case .cantNavigateExternalOriginIsRequired = reason,
                    MediQuo.deeplink(.videoCall, origin: self.slideMenuController(), animated: animated) { result in
                        result.process(doSuccess: { _ in
                            // success
                        }, doFailure: { error in
                            // fail
                        })
                    }           
                    completionHandler()
                } else {
                    completionHandler()
                }
            })
        }

````

- Next step is configure videocall, we can configure many elements from the UI.  To configure Style, you must follow instructions in [Styles](#Styles).
The properties that you need configure are these:

````swift
    // Placeholder for professional when is not assigned
    videoCallIconDoctorNotAssignedImage: UIImage?
    // Backgorund Color for doctor Image background
    videoCallIconDoctorBackgroundColor: UIColor
    // Background image for videocall screen
    videoCallBackgroundImage: UIImage?
    //
    videoCallTopBackgroundImageTintColor: UIColor?
    //
    videoCallBottomBackgroundImageTintColor: UIColor?
    //
    videoCallTopBackgroundColor: UIColor?
    // 
    videoCallBottomBackgroundColor: UIColor?
    // 
    videoCallTitleTextColor: UIColor?
    // 
    videoCallNextAppointmentTextColor: UIColor?
    // 
    videoCallProfessionalNameTextColor: UIColor?
    // 
    videoCallProfessionalSpecialityTextColor: UIColor?
    // 
    videoCallCancelButtonBackgroundColor: UIColor?
    // 
    videoCallAcceptButtonBackgroundColor: UIColor?
    // 
    videoCallCancelButtonTextColor: UIColor?
    // 
    videoCallAcceptButtonTextColor: UIColor?
    // 
    videoCallIconDoctorNotAssignedImageTintColor: UIColor?
````
