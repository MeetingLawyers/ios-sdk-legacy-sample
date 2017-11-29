# Mediquo SDK

A continuación se detallan los pasos a seguir para incluír la librería de MediQuo a un proyecto de aplicación iOS.

## Instalación

Para instalar la librería de MediQuo hay que incluir primero el repositorio privado de pods de MediQuo a la lista de Cocoapods utilizando el siguiente comando:

```
pod repo add mediquo https://gitlab.com/mediquo/specs.git
```

Además, requeriremos de añadir una gema para cargar el podspec con el comando:

```
gem install dotenv --user-install
```

Posteriormente, en el ‘Podfile’ del proyecto añadimos en la cabecera el nuevo origen de pods, además de la cabecera por defecto de Cocoapods: 

```
source 'https://gitlab.com/mediquo/specs.git'
source 'https://github.com/CocoaPods/Specs.git'
```

Y finalmente, incluímos el pod en el target del proyecto con la última versión:

```
pod 'MediQuo', '~> 0.9.1'
```

## Integración
Para utilizar la librería es necesario importar la librería en nuestro AppDelegate, junto con otra dependencia nativa que no se incluye en el framework:

```swift
import MediQuo
```
Seguidamente, en cuanto recibimos aviso del sistema que nuestra aplicación ya está activa, hay que configurar el framework proporcionando el API key del cliente:

```swift
public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
	[...]
	let configuration = MediQuo.Configuration(id: “client_name”, secret: “api_key”)
    MediQuo.initialize(with: configuration, options: launchOptions)
    [...]
}
```

Sin el proceso de inicialización, las llamadas posteriores a la librería desencadenan en resultados de error.


## Autenticación

La autenticación verifica que el token de usuario proporcionado es correcto y, por tanto, puede iniciar el chat.

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

El resultado de la autenticación no devuelve ningún valor más allá de la misma constatación del éxito o fracaso de la operación.

A partir de la respuesta correcta, podemos considerar que el usuario es correcto y el entorno de MediQuo está listo para mostrar las conversaciones activas del usuario.

En el caso de este proyecto de ejemplo se encuentra en la clase *ViewController*

## Mensajes pendientes

Superado el proceso de autenticación podemos consultar entonces los mensajes pendientes por leer que tiene el usuario mediante el siguiente método:

```swift
func unreadMessageCount(_ completion: @escaping (MediQuo.Result<Int>) -> Void)
```

De manera que, una vez obtenemos el resultado, podemos actualizar el distintivo del icono de la aplicación:

```swift
MediQuo.unreadMessageCount { (result: MediQuo.Result<Int>) in
    if let count = result.value {
        UIApplication.shared.applicationIconBadgeNumber = count
    }
}
```

Lista de médicos
Una vez hemos inicializado el SDK y autenticado el usuario, podemos lanzar la UI de MediQuo utilizando el siguiente método:

```swift
func present(animated: Bool = true, 
     completion: ((MediQuo.Result<Void>) -> Void)? = nil)
```

Los parámetros del método se encuentran sobrecargados con valores por defecto. Así pues podemos invocar la lista de médicos añadiendo la siguiente llamada:

```swift
MediQuo.present()
```

Es importante que este método se invoque una vez la aplicación disponga de un ‘UIApplication.keyWindow’, ya que se utiliza para embeber la UI de MediQuo. En caso de no estar presente se devuelve un ‘invalidTopViewController’ en el callback ‘completion’.

No debería representar un problema para la mayoría de aplicaciones, pero sí hay casos especiales en los que esta situación puede ocurrir. Por ejemplo, si utilizamos Storyboards e invocamos este método en el ‘viewDidLoad’ de la pantalla inicial.

Una vez hayamos finalizado las conversaciones, el método ‘dismiss’ cierra la vista del controlador actual y vuelve a la pantalla desde la que fue invocada.

```swift
func dismiss(animated: Bool = true, 
     completion: ((MediQuo.Result<Void>) -> Void)? = nil)
```

Por otro lado en caso de querer recuperar la referecncia al -controller- de chat deberemos usar el siguiente método:
```swift
...
MediQuo.chatController { (controller, result) in
    if let wrapController = controller, result.isSuccess {
        // do some stuff
    }
}
....
```


## Estilos

Los estilos de la lista de médicos se pueden personalizar creando una instancia que cumpla con el protocolo ‘MediQuoStyleType’, modificando sus propiedades para posteriormente vincularlo a la propiedad ‘style’ de la librería.

Por defecto, la propiedad ‘style’ viene ya configurada con unos valores iniciales que encajan con la marca MediQuo y que se utilizan en caso de no sobreescribir el valor de estilo o simplemente inicializarlo a nil.

Propiedades:

```swift
titleFont: UIFont? // Fuente de letra del título de la barra de navegación de lista de médicos.
titleColor: UIColor? // Color de letra del título de la barra de navegación para la lista de médicos y el nombre del médico en la conversación.
navigationBarOpaque: Bool // Modifica la aplicación del color de la barra de navegación al ‘backgroundColor’ o al ‘barTintColor’
navigationBarColor: UIColor? // Color de la barra de navegación
navigationBarTintColor: UIColor? // Color de los elementos de la barra de navegación, tales como el botón de ‘back’ o el ‘leftBarButtonItem’
inboxTitle: String? // Texto del título de la barra de navegación de la lista de médicos
inboxLeftBarButtonItem: UIBarButtonItem? // Botón izquierdo de la barra de navegación de la lista de médicos. Puede personalizarse para poner un botón que invoque el método MediQuo.dismiss() o abra un menú lateral. Por defecto está vacía.
activityIndicatorColor: UIColor? // Color del indicador de carga inicial de la pantalla de lista de médicos.
```

## Notificaciones

La librería de MediQuo utiliza notificaciones push para comunicar a los usuarios de mensajes pendientes. 

En cuanto se inicia la presentación del chat en pantalla, si aún no se han necesitado por parte de la aplicación host los permisos para enviar notificaciones, se muestra el diálogo de seguridad de sistema. Cuando el usuario otorga los permisos necesarios para enviar notificaciones push, es necesario intervenir en las llamadas de sistema para notificar a MediQuo del token de dispositivo. Es necesario añadir los métodos siguientes al AppDelegate:

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


ATENCIÓN:

> Es necesario que la aplicación host disponga de los permisos y entitlements necesarios para recibir notificaciones push.
Es imprescindible proporcionar un certificado APNs .p12 de producción al administrador de su cuenta de MediQuo para que las notificaciones se reciban correctamente.
