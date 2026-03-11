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
│   ├── AppRouter.swift          # Navegación y routing de la app
│   ├── AppView.swift            # Vista principal que contiene toda la UI
│   └── shadowApp.swift          # @main - Clase principal de la aplicación
├── Core/                        # Capa central de negocio e infraestructura
│   ├── Application/             # Lógica de negocio y repositorios
│   │   └── Repositories/
│   │       └── RoomRepository.swift
│   ├── Extensions/              # Extensiones de Swift y utilidades
│   │   └── NotificationCenter+RoomEvents.swift
│   └── Infrastructure/          # Capa de infraestructura técnica
│       ├── Crypto/              # Servicios criptográficos
│       │   └── CryptoService.swift
│       ├── DependencyInjection/
│       │   └── DIContainer.swift
│       ├── Network/             # Comunicación con el servidor
│       │   ├── SocketEvent.swift
│       │   ├── SocketService.swift
│       │   └── SocketServiceProtocol.swift
│       └── Storage/             # Almacenamiento local y seguro
│           ├── KeychainService.swift
│           ├── LocalStorageService.swift
│           └── StorageService.swift
├── DesignSystem/                # Sistema de diseño unificado
│   ├── Components/              # Componentes UI reutilizables
│   │   └── AppButton.swift
│   ├── Extensions/              # Extensiones del Design System
│   │   └── LocalizedText.swift
│   ├── Tokens/                  # Tokens de diseño (colores, etc.)
│   │   ├── Color+Hex.swift
│   │   └── Colors.swift
│   ├── Radius.swift             # Radios de borde
│   ├── Spacing.swift            # Espaciado estándar
│   ├── TextStyles.swift         # Estilos de texto tipográficos
│   └── Typography.swift         # Definiciones de fuentes
├── Features/                    # Módulos de funcionalidad específica
│   ├── Chat/                    # Módulo de chat
│   │   └── Presentation/
│   │       ├── ViewModels/
│   │       │   └── ChatViewModel.swift
│   │       └── Views/
│   │           └── ChatView.swift
│   ├── Connection/              # Manejo de conexión
│   │   └── Presentation/
│   │       └── Views/
│   │           └── NoConnectionView.swift
│   ├── Destruction/             # Lógica de autodestrucción
│   ├── Home/                    # Pantalla principal
│   │   └── Presentation/
│   │       ├── Components/
│   │       │   └── HomeTopBar.swift
│   │       ├── ViewModels/
│   │       │   └── HomeViewModel.swift
│   │       └── Views/
│   │           └── HomeView.swift
│   ├── Onboarding/             # Flujo de bienvenida
│   │   └── Presentation/
│   │       ├── Components/
│   │       │   ├── DotGridBackground.swift
│   │       │   ├── OnboardingProgressBar.swift
│   │       │   ├── OnboardingTopBar.swift
│   │       │   └── StackedCardIcon.swift
│   │       └── Views/
│   │           ├── OnboardingStep1View.swift
│   │           ├── OnboardingStep2View.swift
│   │           ├── OnboardingStep3View.swift
│   │           └── OnboardingView.swift
│   ├── RoomCreation/           # Creación de salas
│   │   └── Presentation/
│   │       ├── Components/
│   │       │   └── RoomCreationTopBar.swift
│   │       ├── ViewModels/
│   │       │   └── RoomCreationViewModel.swift
│   │       └── Views/
│   │           ├── RoomCreatedView.swift
│   │           ├── RoomCreationAliasView.swift
│   │           ├── RoomCreationConfigView.swift
│   │           └── RoomCreationView.swift
│   ├── RoomJoin/               # Unión a salas existentes
│   │   └── Presentation/
│   │       └── Views/
│   │           └── RoomJoinView.swift
│   ├── Security/               # Funcionalidades de seguridad
│   └── Settings/               # Configuración de la app
│       └── Presentation/
│           └── Views/
│               └── SettingsView.swift
└── Info.plist                  # Configuración de la app iOS
```

---

## 🔐 Sistema de Seguridad Criptográfica

### Arquitectura de Almacenamiento Seguro

#### 1. **KeychainService** - Datos Sensibles
**Propósito**: Almacenamiento seguro de claves criptográficas y datos sensibles

**Características**:
- Encriptación nativa de iOS
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

**Métodos**:
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
- Estado del onboarding
- Preferencias de UI
- Configuraciones temporales

#### 3. **StorageService** - Facade Unificado
**Propósito**: Interfaz única que decide automáticamente dónde guardar cada tipo de dato

**Ventajas**:
- Abstracción completa del almacenamiento
- Decisiones automáticas de seguridad
- Interface consistente para toda la app

### CryptoService - Motor Criptográfico

#### 1. **Gestión de Claves ECDH**
```swift
// Generar clave privada
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

**Flujo**:
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

### 3. Inyección de Dependencias (`DIContainer.swift`)
Proporciona los servicios compartidos a toda la aplicación:
- `SocketService`: Gestiona la conexión WebSocket
- `RoomRepository`: Gestiona las salas de chat
- `StorageService`: Facade unificado de almacenamiento
- `CryptoService`: Motor criptográfico E2EE

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
    case keyExchange     = "key:exchange"       // Intercambio de claves
    
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
    
    case keyReceive       = "key:receive"        // Clave recibida
    
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
    
    // Implementaciones falsas para testing
    func encryptMessage(_ data: Data, roomKey: SymmetricKey) -> Data? {
        return data // Sin encriptación para testing
    }
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
