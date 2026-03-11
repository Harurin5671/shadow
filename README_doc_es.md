# Shadow - Chat Seguro con Autodestrucción

## 🌑 ¿Qué es Shadow?

Shadow es una aplicación de chat móvil para iOS desarrollada en Swift/SwiftUI que ofrece comunicación segura y temporal con cifrado de extremo a extremo. Las salas de chat tienen un tiempo de vida limitado y se autodestruyen automáticamente, garantizando que tus conversaciones no permanezcan para siempre.

### 🎯 Propósito Principal

- **Comunicación Efímera**: Chats que desaparecen automáticamente después de un tiempo determinado
- **Seguridad Total**: Cifrado de extremo a extremo con intercambio de claves ECDH
- **Sin Registro**: No requiere creación de cuenta ni datos personales
- **Privacidad Absoluta**: Servidor no tiene acceso al contenido de los mensajes

---

## 🏗️ Arquitectura del Proyecto

### Estructura de Carpetas

```
shadow/
├── App/                          # Punto de entrada y configuración principal
│   ├── AppRouter.swift          # Navegación de la app (Basada en estado)
│   ├── AppView.swift            # Switcher de vista raíz
│   └── shadowApp.swift          # @main - Punto de entrada
├── Core/                        # Lógica de negocio e infraestructura central
│   ├── Application/             # Contextos delimitados y repositorios
│   │   ├── Repositories/
│   │   │   └── RoomRepository.swift
│   │   └── Services/
│   │       └── NotificationManager.swift
│   ├── Extensions/              # Extensiones de Swift específicas del dominio
│   │   └── NotificationCenter+RoomEvents.swift
│   └── Infrastructure/          # Capa de infraestructura técnica
│       ├── Crypto/              # Motor y orquestador de E2EE
│       │   ├── CryptoManager.swift
│       │   └── CryptoService.swift
│       ├── DependencyInjection/
│       │   └── DIContainer.swift
│       ├── Network/             # Comunicación en tiempo real (Socket.io)
│       │   ├── SocketEvent.swift
│       │   ├── SocketService.swift
│       │   └── SocketServiceProtocol.swift
│       ├── Notifications/       # Notificaciones del sistema
│       │   ├── LocalNotificationService.swift
│       │   └── LocalNotificationServiceProtocol.swift
│       └── Storage/             # Capa de persistencia
│           ├── KeychainService.swift
│           ├── LocalStorageService.swift
│           └── StorageService.swift
├── DesignSystem/                # Base visual y componentes
│   ├── Components/              # Elementos UI atómicos
│   ├── Extensions/              # Extensiones de View y Color
│   ├── Tokens/                  # Tokens de diseño semánticos
│   ├── Radius.swift
│   ├── Spacing.swift
│   ├── TextStyles.swift
│   └── Typography.swift
├── Features/                    # Características del dominio (MVVM)
│   ├── Chat/                    # Interfaz de mensajería segura
│   ├── Connection/              # Estados de conectividad
│   ├── Destruction/             # Lógica de auto-eliminación
│   ├── Home/                    # Dashboard y gestión de salas
│   ├── RoomCreation/           # Flujo para crear nuevas salas
│   ├── RoomJoin/               # Flujo para unirse a salas existentes
│   ├── Onboarding/             # Experiencia de primer uso
│   └── Settings/               # Preferencias del usuario
├── Resources/                   # Recursos y cadenas localizables
│   ├── Localizable.xcstrings    # Soporte multi-idioma
│   └── Assets.xcassets
└── Tests/                       # Pruebas unitarias y de UI
```

---

## 🔧 Explicación de Protocolos y Conceptos Clave

### ¿Qué es un Protocolo en Swift?

Un **protocolo** en Swift es como un **contrato** o **plantilla** que define qué funciones y propiedades debe tener una clase, pero no implementa cómo funcionan. Es como definir las reglas de un juego sin decir cómo jugarlo.

#### 📋 Analogía Sencilla:

Imagina que quieres crear diferentes tipos de vehículos:

- Un coche, una moto, una bicicleta

Todos tienen cosas en común: pueden **acelerar**, **frenar** y **girar**. Pero cada uno lo implementa de forma diferente.

```swift
// Este es el PROTOCOLO (el contrato)
protocol Vehiculo {
    func acelerar()
    func frenar()
    func girar(direccion: String)
}

// Estas son las CLASES que cumplen el contrato
class Coche: Vehiculo {
    func acelerar() {
        print("Acelerando con motor de gasolina")
    }

    func frenar() {
        print("Frenando con discos")
    }

    func girar(direccion: String) {
        print("Girando el volante hacia \(direccion)")
    }
}

class Bicicleta: Vehiculo {
    func acelerar() {
        print("Pedaleando más rápido")
    }

    func frenar() {
        print("Apretando las manetas de freno")
    }

    func girar(direccion: String) {
        print("Girando el manillar hacia \(direccion)")
    }
}
```

### Protocolos en Shadow

En Shadow usamos protocolos para organizar el código y hacerlo más mantenible:

#### 1. `SocketServiceProtocol`

**¿Por qué existe?**
Para que la app no dependa directamente de una implementación específica de WebSocket. Podríamos cambiar de SocketIO a otra librería sin tener que modificar toda la app.

**¿Qué define?**

```swift
protocol SocketServiceProtocol {
    var isConnected: Bool { get }           // ¿Estamos conectados?
    var mySocketId: String? { get }          // Cuál es mi ID único

    func connect(url: String)                // Conectar al servidor
    func disconnect()                       // Desconectarse

    func emit(_ event: SocketEmitEvent, _ data: [String: Any])  // Enviar eventos
    func on(_ event: SocketOnEvent, handler: @escaping ([Any]) -> Void)  // Escuchar eventos
    func off(_ event: SocketOnEvent)        // Dejar de escuchar

    func decode<T: Decodable>(_ type: T.Type, from data: [Any]) -> T?  // Decodificar JSON
}
```

**¿Por qué es útil?**

- **Testing**: Podemos crear una versión falsa para pruebas
- **Flexibilidad**: Si mañana queremos usar otra librería, solo cambiamos la implementación
- **Organización**: Separa el "qué" del "cómo"

#### 2. `RoomRepositoryProtocol`

**¿Por qué existe?**
Para separar la lógica de negocio de la UI. La Vista no necesita saber cómo obtenemos las salas, solo necesita saber que puede obtenerlas.

**¿Qué define?**

```swift
protocol RoomRepositoryProtocol {
    var rooms: [RoomInfo] { get }            // Lista de salas
    var isLoading: Bool { get }              // ¿Estamos cargando?

    func loadMyRooms()                       // Cargar mis salas
    func startListening()                    // Empezar a escuchar cambios
    func stopListening()                     // Parar de escuchar

    func removeRoom(withCode code: String)   // Eliminar una sala
    func insertRoom(_ room: RoomInfo, at index: Int)  // Añadir una sala
}
```

---

## 🔄 Flujo de la Aplicación

### 1. Inicio (`shadowApp.swift`)

```swift
@main
struct shadowApp: App {
    @State private var router = AppRouter()
    private let diContainer = DIContainer.shared

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(router)                           // Sistema de navegación
                .environment(diContainer.socketService)         // Conexión WebSocket
                .environment(diContainer.roomRepository)        // Gestión de salas
                .environment(diContainer.storageService)       // Almacenamiento seguro
                .environment(diContainer.cryptoService)         // Servicios criptográficos
                .preferredColorScheme(ColorScheme.dark)
                .task {
                    // Conectar al servidor cuando la app inicia
                    diContainer.socketService.connect(url: "http://localhost:3000")
                }
        }
    }
}
```

### 2. Sistema de Navegación (`AppRouter.swift`)

Controla qué pantalla mostrar usando el patrón de navegación basado en estado:

- **Screens**: Pantallas principales (.onboarding, .main)
- **Destinations**: Destinos de navegación (.roomJoin, .chat, .settings)

### 3. Inyección de Dependencias (`DIContainer.shared`)

Uso de un Singleton seguro para la gestión de dependencias. Todos los servicios se inicializan de forma perezosa o durante el inicio para ser proporcionados vía `@Observable`.

- `SocketService`: Gestión de WebSockets en tiempo real.
- `RoomRepository`: Caché y sincronización de salas a nivel de aplicación.
- `StorageService`: Interfaz unificada para Keychain (Sensible) y LocalStorage (Prefs).
- `CryptoService`: Primitivas criptográficas de bajo nivel (ECDH, AES-256-GCM).
- `CryptoManager`: Orquestador de E2EE de alto nivel.
- `NotificationManager`: Mapeador centralizado de eventos a notificaciones.

---

## 🔐 Sistema de Seguridad Criptográfica

### Arquitectura de Almacenamiento Seguro

#### 1. **KeychainService** - Datos Sensibles

**Propósito**: Almacenamiento seguro de claves criptográficas y datos sensibles

**Características**:

- Encriptación nativa de iOS con Secure Enclave
- `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` - Solo disponible cuando dispositivo está desbloqueado
- Persistencia segura que sobrevive reinstalaciones

**Tipos de claves soportadas**:

```swift
enum KeychainKey {
    case privateKey              // Clave ECDH del usuario
    case roomKey(String)        // Clave AES-256 de sala específica
    case publicKey(String)       // Clave pública para servidor
}
```

**Métodos principales**:

```swift
func save(_ data: Data, forKey key: KeychainKey) -> Bool
func load(forKey key: KeychainKey) -> Data?
func delete(forKey key: KeychainKey) -> Bool
```

#### 2. **LocalStorageService** - Datos No Sensibles

**Propósito**: Almacenamiento de preferencias y configuraciones no críticas

**Características**:

- Usa UserDefaults estándar
- Datos no cifrados (no sensibles)
- Rápido y eficiente para preferencias

**Datos almacenados**:

- Estado del onboarding completado
- Preferencias de UI
- Configuraciones temporales

#### 3. **StorageService** - Facade Unificado

**Propósito**: Interfaz única que decide automáticamente dónde guardar cada tipo de dato

**Ventajas**:

- Abstracción completa del almacenamiento
- Decisiones automáticas de seguridad
- Interface consistente para toda la app

### CryptoManager - Orquestación E2EE

El `CryptoManager` actúa como un orquestador que simplifica flujos criptográficos complejos en una API clara para los ViewModels.

#### 1. **Intercambio de Claves Automatizado**

Cuando un participante se une a una sala, `CryptoManager` maneja automáticamente el broadcast de la clave pública y la generación del secreto compartido.

#### 2. **Distribución de Room Key (Flujo Hospedado)**

Shadow utiliza un modelo de "Claves Hospedadas" donde el creador de la sala genera la `RoomKey` maestra (AES-256) y la comparte individualmente con cada participante vía E2EE (cifrada con ECDH).

```swift
// Flujo del creador en CryptoManager
func setupAsCreator(for roomCode: String, alias: String) {
    let roomKey = crypto.generateRoomKey()
    storage.saveToKeychain(roomKey, forKey: .roomKey(roomCode))
}

// Cuando un participante se une:
private func shareRoomKey(roomCode: String, withPublicKey: P256.PublicKey, toSocketId: String) {
    let sharedSecret = crypto.generateSharedSecret(myPrivate, withPublicKey)
    let wrappedKey = crypto.wrapRoomKey(roomKey, sharedSecret: sharedSecret)
    socket.emit(.roomKeyShare, ["wrappedRoomKey": wrappedKey, ...])
}
```

#### 3. **Flujo de Mensajería**

La encriptación se maneja de forma transparente antes del envío y la desencriptación ocurre al recibir el mensaje.

```swift
// Enviando un mensaje (ChatViewModel)
func sendMessage(message: String) {
    guard let encrypted = cryptoManager.encryptMessage(message, for: roomCode) else { return }
    socket.emit(.messageSend, ["encryptedPayload": encrypted, ...])
}

// Recibiendo un mensaje
socket.on(.messageReceive) { data in
    let text = cryptoManager.decryptMessage(payload.encryptedPayload, for: roomCode)
    // Actualizar UI
}
```

### CryptoService - Motor Criptográfico

#### 1. **Gestión de Claves ECDH**

```swift
// Generar clave privada P256
let privateKey = cryptoService.generatePrivateKey()

// Guardar en Keychain de forma segura
cryptoService.savePrivateKey(privateKey)

// Cargar cuando se necesite
let loadedKey = cryptoService.loadPrivateKey()
```

#### 2. **Intercambio de Claves Seguro**

```swift
// Obtener clave pública para compartir
let publicKey = cryptoService.publicKeyFrom(privateKey)
let publicKeyData = cryptoService.encodePublicKey(publicKey)

// Recibir clave pública de otro participante
let receivedPublicKey = cryptoService.decodePublicKey(publicKeyData)!

// Generar shared secreto (ECDH)
let sharedSecret = cryptoService.generateSharedSecret(
    privateKey: myPrivateKey,
    publicKey: receivedPublicKey
)
```

#### 3. **Sistema de Room Keys (AES-256)**

**Propósito**: Claves simétricas para encriptar mensajes dentro de una sala

**Flujo completo**:

1. **Generación**: `cryptoService.generateRoomKey()` - Crea AES-256
2. **Wrapping**: `cryptoService.wrapRoomKey(roomKey, sharedSecret)` - Encripta room key con ECDH
3. **Unwrapping**: `cryptoService.unwrapRoomKey(wrappedKey, sharedSecret)` - Desencripta room key
4. **Encriptación**: `cryptoService.encryptMessage(message, roomKey)` - Encripta mensajes

#### 4. **Salts Criptográficos Seguros**

```swift
private enum HKDFSalt {
    // Para derivar wrapping key (wrap/unwrap room key via ECDH)
    static let keyWrapping = Data("shadow.e2ee.keyWrapping.v1".utf8)

    // Para encrypt/decrypt directo con shared secret
    static let directEncrypt = Data("shadow.e2ee.directEncrypt.v1".utf8)
}
```

**¿Por qué salts fijos?**

- **Interoperabilidad**: Todos los dispositivos usan el mismo salt
- **No son secretos**: El salt es contexto público, no clave
- **Seguridad real**: Viene de la clave privada ECDH que nunca sale del dispositivo

### Flujo Completo de E2EE en Shadow

#### 1. **Creación de Sala**

```swift
// 1. Generar clave ECDH si no existe
let privateKey = cryptoService.loadPrivateKey() ?? cryptoService.generatePrivateKey()
cryptoService.savePrivateKey(privateKey)

// 2. Generar room key AES-256 para la sala
let roomKey = cryptoService.generateRoomKey()

// 3. Guardar room key en Keychain
let roomKeyData = roomKey.withUnsafeBytes { Data($0) }
storageService.saveToKeychain(roomKeyData, forKey: .roomKey(roomCode))

// 4. Emitir evento de creación con clave pública
let publicKeyData = cryptoService.encodePublicKey(cryptoService.publicKeyFrom(privateKey))
socketService.emit("room:create", [
    "publicKey": publicKeyData.base64EncodedString()
])
```

#### 2. **Unión a Sala**

```swift
// 1. Recibir clave pública del creador
socketService.on("room:joined") { data in
    let creatorPublicKeyData = Data(base64Encoded: creatorPublicKeyString)!
    let creatorPublicKey = cryptoService.decodePublicKey(creatorPublicKeyData)!

    // 2. Generar shared secret ECDH
    let sharedSecret = cryptoService.generateSharedSecret(
        privateKey: myPrivateKey,
        publicKey: creatorPublicKey
    )!

    // 3. Recibir room key encriptada (wrapped)
    let wrappedRoomKey = Data(base64Encoded: wrappedKeyString)!

    // 4. Desencriptar room key con shared secret
    let roomKey = cryptoService.unwrapRoomKey(wrappedRoomKey, sharedSecret: sharedSecret)!

    // 5. Guardar room key para encriptar mensajes
    let roomKeyData = roomKey.withUnsafeBytes { Data($0) }
    storageService.saveToKeychain(roomKeyData, forKey: .roomKey(roomCode))
}
```

#### 3. **Envío de Mensaje**

```swift
// 1. Cargar room key del Keychain
let roomKeyData = storageService.loadFromKeychain(forKey: .roomKey(roomCode))!
let roomKey = SymmetricKey(data: roomKeyData)

// 2. Encriptar mensaje con room key
let messageData = message.data(using: .utf8)!
let encryptedMessage = cryptoService.encryptMessage(messageData, roomKey: roomKey)!

// 3. Enviar mensaje encriptado
socketService.emit("message:send", [
    "roomCode": roomCode,
    "message": encryptedMessage.base64EncodedString()
])
```

#### 4. **Recepción de Mensaje**

```swift
socketService.on("message:receive") { data in
    // 1. Decodificar mensaje encriptado
    let encryptedMessage = Data(base64Encoded: encryptedString)!

    // 2. Cargar room key
    let roomKeyData = storageService.loadFromKeychain(forKey: .roomKey(roomCode))!
    let roomKey = SymmetricKey(data: roomKeyData)

    // 3. Desencriptar mensaje
    let decryptedMessage = cryptoService.decryptMessage(encryptedMessage, roomKey: roomKey)!
    let message = String(data: decryptedMessage, encoding: .utf8)!

    // 4. Mostrar mensaje en UI
    addMessageToChat(message)
}
```

### Eventos de Seguridad

- `securityAlert`: Alertas de amenazas de seguridad
- `deadManCheckIn`: Verificaciones de "hombre muerto" (dead man switch)
- `keyExchange`: Intercambio seguro de claves públicas

### Flujo de Intercambio de Claves (Key Exchange)

#### 1. **Evento `key:exchange`**

**Propósito**: Enviar clave pública a otros participantes de la sala

**Cuándo se usa**:

- Al crear una sala (el creador comparte su clave pública)
- Al unirse a una sala (el nuevo participante comparte su clave pública)
- Cuando un participante se une (todos comparten sus claves públicas)

**Estructura del evento**:

```swift
// Emitir clave pública
socketService.emit("key:exchange", [
    "roomCode": "ABC123",
    "publicKey": "base64EncodedPublicKeyData",
    "participantAlias": "MiAlias"
])

// Recibir clave pública de otros
socketService.on("key:receive") { data in
    let roomCode = data[0] as? String ?? ""
    let publicKeyData = Data(base64Encoded: data[1] as? String ?? "")!
    let participantAlias = data[2] as? String ?? ""

    // Procesar clave pública recibida
    processReceivedPublicKey(from: participantAlias, publicKey: publicKeyData)
}
```

#### 2. **Proceso de Key Exchange Completo**

```swift
// 1. Al unirse a sala, emitir mi clave pública
func joinRoom(roomCode: String) {
    // Generar mi clave ECDH si no existe
    let myPrivateKey = cryptoService.loadPrivateKey() ?? cryptoService.generatePrivateKey()
    cryptoService.savePrivateKey(myPrivateKey)

    // Obtener mi clave pública
    let myPublicKey = cryptoService.publicKeyFrom(myPrivateKey)
    let publicKeyData = cryptoService.encodePublicKey(myPublicKey)

    // Emitir a todos los participantes
    socketService.emit("key:exchange", [
        "roomCode": roomCode,
        "publicKey": publicKeyData.base64EncodedString(),
        "participantAlias": userAlias
    ])
}

// 2. Recibir claves públicas de otros participantes
socketService.on("key:receive") { data in
    guard let roomCode = data[0] as? String,
          let publicKeyString = data[1] as? String,
          let participantAlias = data[2] as? String else { return }

    let publicKeyData = Data(base64Encoded: publicKeyString)!
    let publicKey = cryptoService.decodePublicKey(publicKeyData)!

    // Generar shared secret con este participante
    let myPrivateKey = cryptoService.loadPrivateKey()!
    let sharedSecret = cryptoService.generateSharedSecret(
        privateKey: myPrivateKey,
        publicKey: publicKey
    )!

    // Guardar shared secret para este participante
    // NOTA: Esto permite comunicación 1-a-1 con cada participante
    saveSharedSecret(for: participantAlias, secret: sharedSecret)

    // Si soy el creador, enviar room key encriptada
    if isRoomCreator {
        let roomKey = getOrCreateRoomKey(for: roomCode)
        let wrappedRoomKey = cryptoService.wrapRoomKey(roomKey, sharedSecret: sharedSecret)

        socketService.emit("room:key:share", [
            "roomCode": roomCode,
            "targetParticipant": participantAlias,
            "wrappedRoomKey": wrappedRoomKey.base64EncodedString()
        ])
    }
}
```

#### 3. **Eventos Adicionales para Key Management**

**`room:key:share`** - Compartir room key encriptada:

```swift
// Solo el creador de la sala envía esto
socketService.emit("room:key:share", [
    "roomCode": roomCode,
    "targetParticipant": "aliasDestino",
    "wrappedRoomKey": "roomKeyEncriptadaEnBase64"
])
```

**`room:key:receive`** - Recibir room key encriptada:

```swift
socketService.on("room:key:receive") { data in
    let wrappedRoomKey = Data(base64Encoded: data[0] as? String ?? "")!
    let senderAlias = data[1] as? String ?? ""

    // Desencriptar room key con shared secret del remitente
    let sharedSecret = getSharedSecret(for: senderAlias)!
    let roomKey = cryptoService.unwrapRoomKey(wrappedRoomKey, sharedSecret: sharedSecret)!

    // Guardar room key para enviar/recibir mensajes
    saveRoomKey(roomKey, for: roomCode)
}
```

#### 4. **Flujo Completo de Key Exchange**

1. **Unión a sala**: Emitir clave pública
2. **Recepción**: Recibir claves públicas de otros participantes
3. **Shared Secrets**: Generar shared secret con cada participante
4. **Room Key Distribution**: Creador encripta y comparte room key
5. **Room Key Reception**: Participantes desencriptan y guardan room key
6. **Comunicación**: Usar room key para encriptar mensajes

#### 5. **Escenarios de Key Exchange en Chat**

## 🔄 **Escenario 1: Sala Dinámica (2+ Personas, Crecimiento Variable)**

### **Importante: No es chat 1-a-1 fijo**

- Es **una sala que puede crecer** de 2 a 10+ personas
- Los participantes pueden entrar/salir dinámicamente
- El key exchange debe manejar crecimiento en tiempo real

### **Flujo de Crecimiento de Sala**

```
Estado Inicial: 2 personas
┌─────────────────────────────────────┐
│ Alice (Creadora)    Bob         │
│ 🔒🔓                🔒🔓        │
│ SharedSecret🤫                     │
│ RoomKey🔑                         │
└─────────────────────────────────────┘

Carol se une (3ra persona)
┌─────────────────────────────────────┐
│ Alice (Creadora)    Bob    Carol│
│ 🔒🔓                🔒🔓    🔒🔓│
│ SharedSecret🤫        🤫        🤫│
│ RoomKey🔑                         🔑│
└─────────────────────────────────────┘

David se une (4ta persona)
┌─────────────────────────────────────────────┐
│ Alice    Bob    Carol   David (Nuevo)    │
│ 🔒🔓    🔒🔓    🔒🔓    🔒🔓       │
│ 🤫        🤫        🤫        🤫           │
│ 🔑        🔑        🔑        🔑           │
└─────────────────────────────────────────────┘
```

### **Implementación para Sala Dinámica**

```swift
class DynamicRoomKeyManager {
    private var participants: [String: ParticipantKeys] = [:]
    private var roomKey: SymmetricKey?
    private let roomCode: String
    private let creatorAlias: String

    // 1. INICIO: Creador establece la sala
    func initializeRoom(creatorAlias: String) {
        self.creatorAlias = creatorAlias

        // Creador genera su clave ECDH
        let creatorKey = cryptoService.generatePrivateKey()
        cryptoService.savePrivateKey(creatorKey)

        // Creador genera room key inicial
        let initialRoomKey = cryptoService.generateRoomKey()
        self.roomKey = initialRoomKey

        // Creador se guarda a sí mismo como participante
        let creatorPublicKey = cryptoService.publicKeyFrom(creatorKey)
        participants[creatorAlias] = ParticipantKeys(
            alias: creatorAlias,
            publicKey: creatorPublicKey,
            sharedSecret: nil, // El creador no necesita shared secret consigo mismo
            roomKey: initialRoomKey
        )

        // Emitir clave pública del creador
        let publicKeyData = cryptoService.encodePublicKey(creatorPublicKey)
        socketService.emit("key:exchange", [
            "roomCode": roomCode,
            "publicKey": publicKeyData,
            "participantAlias": creatorAlias
        ])
    }

    // 2. NUEVO PARTICIPANTE: Alguien se une
    func onNewParticipantJoined(alias: String, publicKeyData: Data) {
        print("👋 Nuevo participante: \(alias)")

        // Decodificar clave pública del nuevo participante
        let newParticipantPublicKey = cryptoService.decodePublicKey(publicKeyData)!

        // Cada participante existente genera shared secret con el nuevo
        for (existingAlias, existingParticipant) in participants {
            let myPrivateKey = cryptoService.loadPrivateKey()!

            let sharedSecret = cryptoService.generateSharedSecret(
                privateKey: myPrivateKey,
                publicKey: newParticipantPublicKey
            )!

            // Guardar shared secret para comunicación con este participante
            participants[existingAlias]?.sharedSecretWithNew = sharedSecret
        }

        // El nuevo participante genera shared secrets con todos los existentes
        let newPrivateKey = cryptoService.generatePrivateKey()
        let sharedSecretsForNew: [String: SharedSecret] = [:]

        for (existingAlias, existingParticipant) in participants {
            let sharedSecret = cryptoService.generateSharedSecret(
                privateKey: newPrivateKey,
                publicKey: existingParticipant.publicKey
            )!
            sharedSecretsForNew[existingAlias] = sharedSecret
        }

        // Agregar nuevo participante al sistema
        participants[alias] = ParticipantKeys(
            alias: alias,
            publicKey: newParticipantPublicKey,
            sharedSecretWithExisting: sharedSecretsForNew,
            roomKey: nil // Aún no tiene room key
        )

        // El creador envía room key al nuevo participante
        if roomKey != nil {
            sendRoomKeyToParticipant(alias)
        }

        // Notificar a todos sobre el nuevo participante
        broadcastParticipantUpdate()
    }

    // 3. ENVIAR ROOM KEY: Creador comparte con nuevo participante
    private func sendRoomKeyToParticipant(_ participantAlias: String) {
        guard let roomKey = roomKey,
              let participant = participants[participantAlias] else { return }

        // Usar el shared secret entre creador y este participante
        let sharedSecret = participant.sharedSecretWithCreator ?? generateSharedSecretWithCreator(participant.publicKey)

        let wrappedRoomKey = cryptoService.wrapRoomKey(roomKey, sharedSecret: sharedSecret)

        socketService.emit("room:key:share", [
            "roomCode": roomCode,
            "targetParticipant": participantAlias,
            "wrappedRoomKey": wrappedRoomKey.base64EncodedString(),
            "senderAlias": creatorAlias
        ])

        print("🔑 Room key enviada a \(participantAlias)")
    }

    // 4. PARTICIPANTE RECIBE ROOM KEY
    func onRoomKeyReceived(wrappedKeyData: Data, from senderAlias: String) {
        guard let participant = participants[senderAlias] else { return }

        // Usar el shared secret con quien envió la room key
        let sharedSecret = participant.sharedSecretWithSender

        let roomKey = cryptoService.unwrapRoomKey(wrappedKeyData, sharedSecret: sharedSecret)

        // Guardar room key para este participante
        participants[senderAlias]?.roomKey = roomKey

        print("🔓 \(senderAlias) recibió room key. ¡Listo para chatear!")

        // Si es el primer participante en recibir room key, notificar a todos
        if countParticipantsWithRoomKey() == 1 {
            broadcastRoomReady()
        }
    }

    // 5. MENSAJES: Cualquiera puede enviar a todos
    func sendMessageToAll(_ message: String) {
        guard let roomKey = roomKey else {
            print("❌ Room key no disponible aún")
            return
        }

        let messageData = message.data(using: .utf8)!
        let encryptedMessage = cryptoService.encryptMessage(messageData, roomKey: roomKey)!

        // Enviar mismo mensaje encriptado para todos
        for participantAlias in participants.keys {
            socketService.emit("message:send", [
                "roomCode": roomCode,
                "targetParticipant": participantAlias,
                "message": encryptedMessage.base64EncodedString(),
                "senderAlias": getCurrentUserAlias()
            ])
        }

        print("📨 Mensaje enviado a \(participants.count) participantes")
    }

    // 6. PARTICIPANTE SE VA: Limpieza de claves
    func onParticipantLeft(alias: String) {
        participants.removeValue(forKey: alias)

        print("👋 \(alias) salió de la sala")

        // Opcional: Rotar room key por seguridad
        if shouldRotateRoomKeyOnLeave() {
            rotateRoomKeyForRemainingParticipants()
        }

        // Notificar a los demás
        broadcastParticipantUpdate()
    }

    // 7. UTILIDADES
    private func countParticipantsWithRoomKey() -> Int {
        return participants.values.filter { $0.roomKey != nil }.count
    }

    private func broadcastParticipantUpdate() {
        let participantList = participants.keys.joined(separator: ",")
        socketService.emit("room:participants:update", [
            "roomCode": roomCode,
            "participants": participantList,
            "count": participants.count
        ])
    }

    private func broadcastRoomReady() {
        socketService.emit("room:ready", [
            "roomCode": roomCode,
            "message": "¡La sala está lista para chat E2EE!"
        ])
    }
}

// Estructura mejorada para participantes dinámicos
struct ParticipantKeys {
    let alias: String
    let publicKey: P256.KeyAgreement.PublicKey

    // Para el creador: shared secrets con cada participante
    var sharedSecretWithParticipant: [String: SharedSecret] = [:]

    // Para participantes: shared secret con el creador
    var sharedSecretWithCreator: SharedSecret?

    // Para nuevos participantes: shared secrets con existentes
    var sharedSecretWithExisting: [String: SharedSecret] = [:]
    var sharedSecretWithSender: SharedSecret?

    // Room key (cuando se recibe)
    var roomKey: SymmetricKey?
}
```

### **Flujo Visual de Sala Dinámica**

```
🏠 Sala "ABC123" - Creada por Alice

┌─ INICIO ─────────────────────┐
│ Alice crea sala                │
│ Genera: 🔒🔓 + 🔑        │
│ Emite: key:exchange          │
└────────────────────────────────┘
          │
          ▼
┌─ Bob se une ──────────────────┐
│ Bob genera 🔒🔓              │
│ Emite: key:exchange          │
│ Recibe: 🔓 de Alice         │
│ Calcula: 🤫 (Alice+Bob)     │
└────────────────────────────────┘
          │
          ▼
┌─ Alice envía Room Key ────────┐
│ Encripta 🔑 con 🤫           │
│ Envía: room:key:share        │
│ Bob recibe y desencripta 🔑     │
└────────────────────────────────┘
          │
          ▼
┌─ Carol se une ─────────────────┐
│ Carol genera 🔒🔓             │
│ Emite: key:exchange          │
│ Todos reciben 🔓 de Carol      │
│ Todos calculan 🤫 con Carol    │
│ Alice envía 🔑 a Carol       │
└────────────────────────────────┘
          │
          ▼
┌─ David se une ─────────────────┐
│ David genera 🔒🔓             │
│ Emite: key:exchange          │
│ Todos reciben 🔓 de David      │
│ Todos calculan 🤫 con David    │
│ Alice envía 🔑 a David       │
└────────────────────────────────┘
          │
          ▼
┌─ CHAT E2EE TOTAL ────────────┐
│ Todos tienen 🔑               │
│ Todos pueden encriptar/desencriptar │
│ Servidor no puede leer NADA   │
│ Sala lista para 10+ personas   │
└────────────────────────────────┘
```

### **Casos de Uso Reales**

#### **Reunión de Equipo (5-10 personas)**

```
1. Manager crea sala y envía código
2. Miembros se unen uno por uno
3. Cada nuevo miembro recibe room key del manager
4. Todos pueden colaborar con E2EE
5. Si alguien se va, las claves se limpian automáticamente
```

#### **Clase Virtual (20+ estudiantes)**

```
1. Profesor crea sala y comparte código
2. Estudiantes se unen dinámicamente
3. Cada estudiante obtiene room key al unirse
4. Todos pueden participar con privacidad total
5. Servidor no ve contenido de la clase
```

#### **Evento Público (50+ personas)**

```
1. Organizador crea sala masiva
2. Asistentes se unen continuamente
3. Sistema escala automáticamente
4. Room key se distribuye a cada nuevo participante
5. Chat privado incluso en evento público
```

### **Ventajas de Este Enfoque**

✅ **Escalabilidad**: Soporta de 2 a 50+ participantes  
✅ **Seguridad**: Cada comunicación es E2EE  
✅ **Flexibilidad**: Gente entra/sale dinámicamente  
✅ **Simplicidad**: 1 room key para todos  
✅ **Zero Knowledge**: Servidor no puede descifrar

⚠️ **Complejidad**: Manejo de múltiples shared secrets  
⚠️ **Sincronización**: Requiere coordinación precisa

---

## 🌐 **Escenario 2: Chat Grupal (3+ Personas)**

### **Flujo Complejo**

```
Creador (Alice)           Bob (1er participante)    Carol (2da participante)
     │                            │                           │
     │ 1. Crea sala               │                           │
     │ 2. Genera keyECDH           │                           │
     │ 3. Emite key:exchange        │                           │
     ├─────────────────────────────→│ 4. Recibe pública           │
     │                            │ 5. Genera keyECDH          │
     │                            │ 6. Emite key:exchange        │
     │←─────────────────────────────┤ 7. Recibe pública           │
     │                            │ 8. Genera sharedSecret      │
     │                            │ 9. Guarda sharedSecret      │
     │                            │                           │10. Carol se une
     │                            │                           │11. Genera keyECDH
     │                            │                           │12. Emite key:exchange
     │                            │←───────────────────────────→│13. Alice recibe
     │                            │14. Genera sharedSecret      │
     │                            │15. Guarda sharedSecret      │
     │16. Distribuye room key──────→│17. Recibe wrappedKey        │
     │    a cada uno               │18. Desencripta roomKey      │
     ├─────────────────────────────→│19. Recibe wrappedKey        │
     │                            │20. Desencripta roomKey      │
     │21. Todos pueden chatear─────┤22. Todos pueden chatear
```

### **Implementación con Múltiples Participantes**

```swift
class MultiParticipantKeyManager {
    private var participants: [String: ParticipantKeys] = [:]
    private var roomKey: SymmetricKey?
    private let roomCode: String

    // 1. Cuando alguien se une a la sala
    func onParticipantJoined(alias: String, publicKeyData: Data) {
        let publicKey = cryptoService.decodePublicKey(publicKeyData)!
        let myPrivateKey = cryptoService.loadPrivateKey()!

        let sharedSecret = cryptoService.generateSharedSecret(
            privateKey: myPrivateKey,
            publicKey: publicKey
        )!

        participants[alias] = ParticipantKeys(
            alias: alias,
            publicKey: publicKey,
            sharedSecret: sharedSecret
        )

        // Si soy el creador, enviar room key a este participante
        if amICreator {
            sendRoomKey(to: alias)
        }
    }

    // 2. Enviar room key a participante específico
    private func sendRoomKey(to participantAlias: String) {
        guard let participant = participants[participantAlias],
              let roomKey = roomKey else { return }

        let wrappedKey = cryptoService.wrapRoomKey(
            roomKey,
            sharedSecret: participant.sharedSecret
        )

        socketService.emit("room:key:share", [
            "roomCode": roomCode,
            "targetParticipant": participantAlias,
            "wrappedRoomKey": wrappedKey.base64EncodedString()
        ])
    }

    // 3. Recibir room key del creador
    func onRoomKeyReceived(wrappedKeyData: Data, from creatorAlias: String) {
        guard let creator = participants[creatorAlias] else { return }

        let roomKey = cryptoService.unwrapRoomKey(
            wrappedKeyData,
            sharedSecret: creator.sharedSecret
        )

        self.roomKey = roomKey
        saveRoomKey(roomKey, for: roomCode)
    }

    // 4. Cifrar mensaje para todos los participantes
    func encryptMessage(_ message: String) -> [String: String] {
        guard let roomKey = roomKey else { return [:] }

        let messageData = message.data(using: .utf8)!
        let encryptedMessage = cryptoService.encryptMessage(messageData, roomKey: roomKey)!

        // El mismo mensaje encriptado para todos
        var results: [String: String] = [:]
        for participant in participants.keys {
            results[participant] = encryptedMessage.base64EncodedString()
        }
        return results
    }
}
```

---

## 🔄 **Escenario 3: Chat Dinámico (Entradas/Salidas)**

### **Manejo de Ciclo de Vida**

```swift
class DynamicRoomManager {
    private var keyManager = MultiParticipantKeyManager()

    // 1. Cuando alguien se une
    func handleParticipantJoin(alias: String, publicKeyData: Data) {
        // Agregar participante al sistema de claves
        keyManager.onParticipantJoined(alias: alias, publicKeyData: publicKeyData)

        // Notificar a todos los participantes existentes
        broadcastParticipantList()

        // Si hay room key compartida, notificar al nuevo participante
        if keyManager.hasRoomKey {
            keyManager.sendRoomKey(to: alias)
        }
    }

    // 2. Cuando alguien se va
    func handleParticipantLeft(alias: String) {
        // Eliminar claves de este participante
        keyManager.removeParticipant(alias)

        // Notificar a los demás
        broadcastParticipantList()

        // Opcional: Rotar room key por seguridad
        if shouldRotateRoomKey() {
            rotateRoomKey()
        }
    }

    // 3. Rotación de room key (opcional pero recomendado)
    private func rotateRoomKey() {
        let newRoomKey = cryptoService.generateRoomKey()
        keyManager.updateRoomKey(newRoomKey)

        // Enviar nueva room key a todos los participantes activos
        for participant in keyManager.getActiveParticipants() {
            keyManager.sendRoomKey(to: participant)
        }
    }
}
```

---

## ⚡ **Escenario 4: Chat Anónimo Temporal**

### **Sin Identidad Persistente**

```swift
class AnonymousChatManager {
    private var tempKeys: [String: P256.KeyAgreement.PrivateKey] = [:]

    // 1. Generar clave temporal por sala
    func joinAnonymously(roomCode: String) {
        let tempKey = cryptoService.generatePrivateKey()
        tempKeys[roomCode] = tempKey

        let publicKey = cryptoService.encodePublicKey(
            cryptoService.publicKeyFrom(tempKey)
        )

        socketService.emit("key:exchange", [
            "roomCode": roomCode,
            "publicKey": publicKey,
            "participantAlias": "Anónimo\(Int.random(in: 1000...9999))"
        ])
    }

    // 2. Limpiar claves al salir
    func leaveRoom(roomCode: String) {
        tempKeys.removeValue(forKey: roomCode)

        // Opcional: Eliminar del Keychain también
        cryptoService.deleteRoomKey(for: roomCode)
    }
}
```

---

## 📊 **Resumen de Escenarios**

| Escenario    | Complejidad | Room Keys             | Shared Secrets   | Casos de Uso                  |
| ------------ | ----------- | --------------------- | ---------------- | ----------------------------- |
| **1-a-1**    | Simple      | 1 room key            | 1 shared secret  | Chat privado, soporte técnico |
| **Grupal**   | Media       | 1 room key            | N shared secrets | Reuniones, equipos            |
| **Dinámico** | Alta        | 1 room key (rotativa) | N shared secrets | Salas públicas, eventos       |
| **Anónimo**  | Media       | 1 room key            | 1 shared secret  | Chat temporal, confesiones    |

### **Consideraciones de Seguridad por Escenario**

#### **1-a-1**

- ✅ **Más simple**: Menos puntos de fallo
- ✅ **Más rápido**: Menos operaciones criptográficas
- ⚠️ **Menos escalable**: No soporta más participantes

#### **Grupal**

- ✅ **Escalable**: Soporta N participantes
- ✅ **Eficiente**: 1 room key para todos
- ⚠️ **Complejo**: Manejo de múltiples shared secrets
- ⚠️ **Punto único de fallo**: Si room key se compromete

#### **Dinámico**

- ✅ **Seguro**: Rotación periódica de claves
- ✅ **Flexible**: Maneja entradas/salidas
- ⚠️ **Complejidad máxima**: Requiere sincronización
- ⚠️ **Sobrecarga**: Más operaciones criptográficas

#### **Anónimo**

- ✅ **Privacidad**: Sin identidad persistente
- ✅ **Temporal**: Claves se destruyen automáticamente
- ⚠️ **Sin persistencia**: Se pierde al cerrar app
- ⚠️ **Sin recuperación**: Si se pierde la clave, no hay backup

---

## 🌐 Comunicación WebSocket

### Eventos Emitidos (Cliente → Servidor)

```swift
enum SocketEmitEvent: String {
    case roomCreate      = "room:create"        // Crear sala
    case roomJoin        = "room:join"          // Unirse a sala
    case roomGetMyRooms  = "room:getMyRooms"    // Obtener mis salas
    case roomDestroy     = "room:destroy"       // Destruir sala

    case messageSend     = "message:send"       // Enviar mensaje
    case keyExchange     = "key:exchange"       // Intercambio de claves públicas
    case roomKeyShare    = "room:key:share"     // Compartir room key encriptada

    case securityAlert   = "security:alert"     // Alertas de seguridad
    case deadManCheckIn  = "deadman:checkin"    // Verificación activa
    case deadManWarning  = "deadman:warning"    // Advertencia de inactividad

    case typingStart     = "typing:start"       // Usuario escribiendo
    case typingStop      = "typing:stop"        // Usuario dejó de escribir
}
```

### Eventos Recibidos (Servidor → Cliente)

```swift
enum SocketOnEvent: String {
    case roomCreated      = "room:created"       // Sala creada
    case roomJoined       = "room:joined"        // Unido a sala
    case myRooms          = "room:myRooms"       // Lista de mis salas
    case roomDestroyed    = "room:destroyed"     // Sala destruida
    case roomExpired      = "room:expired"       // Sala expirada

    case participantJoined = "participant:joined" // Alguien se unió
    case participantLeft   = "participant:left"   // Alguien se fue

    case messageReceive   = "message:receive"     // Mensaje recibido
    case messageSent      = "message:sent"       // Mensaje enviado

    case keyReceive       = "key:receive"        // Clave pública recibida
    case roomKeyReceive  = "room:key:receive"   // Room key encriptada recibida

    case securityAlert    = "security:alert"      // Alerta de seguridad
    case deadManConfirmed = "deadman:confirmed"  // Verificación confirmada
    case deadManWarning   = "deadman:warning"     // Advertencia recibida

    case typingStart      = "typing:start"       // Alguien está escribiendo
    case typingStop       = "typing:stop"        // Alguien dejó de escribir

    case error            = "error"              // Error del servidor
}
```

---

## 🎨 Sistema de Diseño

### Tipografía

Shadow utiliza una combinación de fuentes modernas:

- **Syne**: Para títulos y elementos destacados
- **JetBrains Mono**: Para código y elementos técnicos
- **Space Grotesk**: Para texto corporativo

### Colores

- **Oscuro**: Tema principal para privacidad
- **Acentos**: Amarillo (#E7FF47) y Cian (#47FFE8) para elementos importantes
- **Superficies**: Gradientes sutiles para profundidad

### Componentes

- **AppButton**: Botón reutilizable con múltiples estilos
- **ActiveRoomCard**: Tarjeta para mostrar salas activas
- **HomeTopBar**: Barra superior personalizada

---

## 📱 Flujo de Usuario

### 1. Onboarding (Primera vez)

- Paso 1: Explicación de privacidad y seguridad
- Paso 2: Demostración de autodestrucción
- Paso 3: Tutorial de uso básico

### 2. Pantalla Principal

- Lista de salas activas con tiempo restante
- Botón para crear nueva sala
- Botón para unirse con código

### 3. Creación de Sala

- Configuración de tiempo de vida
- Establecimiento de alias
- Generación de código único

### 4. Chat

- Mensajes cifrados en tiempo real
- Indicadores de escritura
- Contador de autodestrucción

---

## 🔧 Tecnologías Utilizadas

### Core Framework

- **SwiftUI**: Framework de UI declarativo de Apple
- **Combine**: Programación reactiva (implícito en @Observable)
- **Foundation**: Clases base de iOS
- **CryptoKit**: Framework criptográfico nativo de Apple

### Comunicación

- **SocketIO**: Biblioteca para comunicación WebSocket en tiempo real
- **JSON**: Serialización de datos

### Seguridad

- **Keychain Services**: Almacenamiento seguro de claves
- **ECDH (P256)**: Intercambio de claves de curva elíptica
- **AES-256-GCM**: Encriptación simétrica de mensajes
- **HKDF**: Derivación de claves con salts específicos

### Arquitectura

- **MVVM**: Model-View-ViewModel para separación de responsabilidades
- **Dependency Injection**: Inyección de dependencias para testing y modularidad
- **Repository Pattern**: Abstracción de acceso a datos
- **Observer Pattern**: Para actualizaciones reactivas de UI
- **Facade Pattern**: StorageService como fachada unificada

---

## 🚀 Cómo Ejecutar el Proyecto

### Requisitos Previos

- Xcode 15.0 o superior
- iOS 17.0 o superior
- Servidor WebSocket corriendo en `http://localhost:3000`

### Pasos

1. Clonar el repositorio
2. Abrir `shadow.xcodeproj` en Xcode
3. Seleccionar un dispositivo iOS o simulador
4. Presionar Cmd+R para ejecutar

### Configuración del Servidor

El proyecto espera un servidor WebSocket con los siguientes eventos:

- Conexión en `http://localhost:3000`
- Soporte para todos los eventos definidos en `SocketEvent.swift`
- Manejo de claves públicas y room keys encriptadas
- Soporte para transmisión de datos base64 para claves criptográficas

---

## 🧪 Testing

### Testing de UI

- **shadowUITests**: Pruebas automatizadas de interfaz
- **shadowUITestsLaunchTests**: Pruebas de lanzamiento

### Testing Unitario

- **shadowTests**: Pruebas unitarias de lógica de negocio

### Testing de Criptografía

Los protocolos facilitan el testing al permitir crear implementaciones mock:

```swift
class MockCryptoService: CryptoServiceProtocol {
    func generatePrivateKey() -> P256.KeyAgreement.PrivateKey {
        // Clave de prueba predecible
        return P256.KeyAgreement.PrivateKey()
    }

    func encryptMessage(_ data: Data, roomKey: SymmetricKey) -> Data? {
        return data // Sin encriptación para testing
    }

    // Implementaciones falsas para testing
    func savePrivateKey(_ key: P256.KeyAgreement.PrivateKey) -> Bool { return true }
    func loadPrivateKey() -> P256.KeyAgreement.PrivateKey? { return nil }
}
```

---

## 🔮 Características Futuras

### Planificadas

- [ ] Cifrado de imágenes y archivos
- [ ] Modo oscuro/claro personalizable
- [ ] Notificaciones push cifradas
- [ ] Verificación de identidad con Face ID
- [ ] Salas privadas con contraseña
- [ ] Perfect Forward Secrecy (PFS)

### En Desarrollo

- [ ] Implementación completa del chat E2EE
- [ ] Sistema de autodestrucción avanzado
- [ ] Análisis de seguridad en tiempo real
- [ ] Key rotation automático

---

## 📄 Licencia

Este proyecto es software privado y propietario. Todos los derechos reservados.

---

## 🤝 Contribuir

Este es un proyecto personal desarrollado por Frank Erick Santos Gonzales. Para colaboraciones o preguntas, contactar directamente.

---

## 📞 Soporte

Para reportar problemas o solicitar características:

1. Revisa la sección de Testing
2. Verifica la conexión del servidor WebSocket
3. Revisa los logs en la consola de Xcode
4. Verifica la configuración del Keychain

---

## 🔐 Consideraciones de Seguridad Adicionales

### Threat Model

- **Servidor**: No tiene acceso a claves privadas ni contenido de mensajes
- **Red**: Todos los mensajes viajan encriptados end-to-end
- **Dispositivo**: Claves protegidas por Keychain con biometría
- **Backup**: Las claves no se incluyen en backups de iCloud

### Best Practices Implementadas

- **Zero Knowledge**: Servidor no puede descifrar mensajes
- **Key Separation**: Claves diferentes para cada propósito
- **Secure Enclave**: Claves privadas nunca salen del hardware seguro
- **Memory Safety**: Limpieza explícita de datos sensibles en memoria

---

**Shadow - Donde la privacidad es temporal, pero la seguridad es eterna.** 🌑
