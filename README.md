[![BuddyBuild](https://dashboard.buddybuild.com/api/statusImage?appID=5a2464d0c5dd1600018b73bd&branch=master&build=latest)](https://dashboard.buddybuild.com/apps/5a2464d0c5dd1600018b73bd/build/latest?branch=master)

# Mediquo SDK

Here are the steps to follow to include the MediQuo library to an iOS application project.

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
pod 'MediQuo', '~> 0.12'
```

## Access permissions

Access to camera or photo gallery always requires explicit permission from the user.

Your app must provide an explanation for its use of capture devices using the **NSCameraUsageDescription** and **NSPhotoLibraryUsageDescription** Info.plist key. iOS displays this explanation when initially asking the user for permission to attach an element in the current conversation. 

⚠️ Attempting to attach a gallery photo or start a camera session without an usage description will raise an exception.

## Integration

To use the library is necessary to import it in our AppDelegate:

```swift
import MediQuo
```

Next, as soon as we receive a notification from the system telling that our application is already active, we must configure the framework by providing the client's API key:

```swift
public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    [...]
    let configuration = MediQuo.Configuration(id: “client_name”, secret: “api_key”)
    MediQuo.initialize(with: configuration, options: launchOptions)
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

From a successful answer, we can consider that the user is authenticated and MediQuo environment is ready to show the active conversations of the user.

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

## Inbox contact list

Once we initialized the SDK and authenticated the user, we can launch the MediQuo UI using the following method:

```swift
func present(animated: Bool = true, 
     completion: ((MediQuo.Result<Void>) -> Void)? = nil)
```

Method parameters have been overloaded with default values. So we can invoke the list of doctors by adding the following call:

```swift
MediQuo.present()
```

It is important to invoke this method once the application has a 'UIApplication.keyWindow', since it is used to embed the MediQuo UI. In case of not being present, an 'invalidTopViewController' error is returned in the 'completion' callback.

It should not be a problem for most applications, but there are special cases in which this situation can occur. For example, if we use Storyboards and we invoke it in 'viewDidLoad' method of the initial view controller. This happens because 'UIApplication.keyWindow' is not set until 'viewDidAppear'.

Once we have finished the conversations, with 'dismiss' method we close the view of the current controller and return to the screen from which it was invoked.

```swift
func dismiss(animated: Bool = true, 
     completion: ((MediQuo.Result<Void>) -> Void)? = nil)
```

On the other hand, if you want to retrieve the reference to the *inbox controller* of chats we must use the following method:

```swift
[...]
MediQuo.chatController { (controller, result) in
    if let wrapController = controller, result.isSuccess {
        // do some stuff
    }
}
[...]
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

// Title of the inbox navigation bar
inboxTitle: String?

// Left bar button item to use as child navigation item. It can be customized to put a button that invokes the MediQuo.dismiss() method or open a side menu. By default it is empty.
inboxLeftBarButtonItem: UIBarButtonItem?

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
    .add(selector: { (speciality, authorized) in
        NSLog("[LaunchScreenViewController] Inbox item '\(speciality)' selected and authorized '\(authorized)'")
        return
    })
```
Configuration closure will be called every time the divider cell appears in the list so the user can update view values.

Selector will be called on every user interaction over the cell (i.e. did select row)

Both values are optional and it is not mandatory to implement them.

## Push notifications

MediQuo library uses push notifications to communicate to users of pending messages.

As soon as the on-screen chat presentation starts, if permissions to send notifications have not yet been needed by the host application, the system security dialog is displayed. When the user grants the necessary permissions to send push notifications, it is mandatory to intervene system remote notification calls to notify MediQuo with the new device token. To do so, we require to add the following methods to the AppDelegate:

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
    MediQuo.didReceiveRemoteNotification(with: userInfo)
}
```

⚠️ WARNING:

> It is necessary that the host application has the necessary permissions and entitlements to receive push notifications.

> It is essential to provide an APNs .p12 production certificate to the administrator of your MediQuo account so that notifications are received correctly.
