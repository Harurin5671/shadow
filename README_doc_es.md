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
│       ├── DependencyInjection/
│       │   └── DIContainer.swift
│       └── Network/             # Comunicación con el servidor
│           ├── SocketEvent.swift
│           ├── SocketService.swift
│           └── SocketServiceProtocol.swift
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
│   │       │   └── SegmentedCardIcon.swift
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
                .environment(router)                    // Sistema de navegación
                .environment(diContainer.socketService)  // Conexión WebSocket
                .environment(diContainer.roomRepository) // Gestión de salas
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

---

## 🔐 Sistema de Seguridad

### Cifrado de Extremo a Extremo

Shadow utiliza criptografía asimétrica ECDH (Elliptic Curve Diffie-Hellman):

1. **Generación de Claves**: Cada usuario genera un par de claves (pública/privada)
2. **Intercambio de Claves**: Los usuarios intercambian sus claves públicas
3. **Clave Compartida**: Se genera una clave compartida única para cada conversación
4. **Cifrado de Mensajes**: Los mensajes se cifran con esta clave compartida
5. **Autodestrucción**: Las claves y mensajes se eliminan cuando la sala expira

### Eventos de Seguridad

- `securityAlert`: Alertas de amenazas de seguridad
- `deadManCheckIn`: Verificaciones de "hombre muerto" (dead man switch)
- `keyExchange`: Intercambio seguro de claves

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

### Comunicación
- **SocketIO**: Biblioteca para comunicación WebSocket en tiempo real
- **JSON**: Serialización de datos

### Arquitectura
- **MVVM**: Model-View-ViewModel para separación de responsabilidades
- **Dependency Injection**: Inyección de dependencias para testing y modularidad
- **Repository Pattern**: Abstracción de acceso a datos
- **Observer Pattern**: Para actualizaciones reactivas de UI

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

---

## 🧪 Testing

### Testing de UI
- **shadowUITests**: Pruebas automatizadas de interfaz
- **shadowUITestsLaunchTests**: Pruebas de lanzamiento

### Testing Unitario
- **shadowTests**: Pruebas unitarias de lógica de negocio

### Testing de Protocolos
Los protocolos facilitan el testing al permitir crear implementaciones mock:
```swift
class MockSocketService: SocketServiceProtocol {
    var isConnected: Bool = false
    var mySocketId: String? = "test-id"
    
    // Implementaciones falsas para testing
    func connect(url: String) { /* simulación */ }
    // ...
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

### En Desarrollo
- [ ] Implementación completa del chat
- [ ] Sistema de autodestrucción avanzado
- [ ] Análisis de seguridad en tiempo real

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

---

**Shadow - Donde la privacidad es temporal, pero la seguridad es eterna.** 🌑
