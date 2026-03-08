# Shadow - Secure Self-Destructing Chat

## 🌑 What is Shadow?

Shadow is a mobile chat application for iOS developed in Swift/SwiftUI that offers secure and temporary communication with end-to-end encryption. Chat rooms have a limited lifetime and self-destruct automatically, ensuring your conversations don't last forever.

### 🎯 Main Purpose

- **Ephemeral Communication**: Chats that automatically disappear after a set time
- **Total Security**: End-to-end encryption with ECDH key exchange
- **No Registration**: No account creation or personal data required
- **Absolute Privacy**: Server has no access to message content

---

## 🏗️ Project Architecture

### Folder Structure

```
shadow/
├── App/                          # Entry point and main configuration
│   ├── AppRouter.swift          # App navigation and routing
│   ├── AppView.swift            # Main view containing all UI
│   └── shadowApp.swift          # @main - Main application class
├── Core/                        # Core business logic and infrastructure
│   ├── Application/             # Business logic and repositories
│   │   └── Repositories/
│   │       └── RoomRepository.swift
│   ├── Extensions/              # Swift extensions and utilities
│   │   └── NotificationCenter+RoomEvents.swift
│   └── Infrastructure/          # Technical infrastructure layer
│       ├── DependencyInjection/
│       │   └── DIContainer.swift
│       └── Network/             # Server communication
│           ├── SocketEvent.swift
│           ├── SocketService.swift
│           └── SocketServiceProtocol.swift
├── DesignSystem/                # Unified design system
│   ├── Components/              # Reusable UI components
│   │   └── AppButton.swift
│   ├── Extensions/              # Design system extensions
│   │   └── LocalizedText.swift
│   ├── Tokens/                  # Design tokens (colors, etc.)
│   │   ├── Color+Hex.swift
│   │   └── Colors.swift
│   ├── Radius.swift             # Border radius
│   ├── Spacing.swift            # Standard spacing
│   ├── TextStyles.swift         # Typography styles
│   └── Typography.swift         # Font definitions
├── Features/                    # Specific functionality modules
│   ├── Chat/                    # Chat module
│   │   └── Presentation/
│   │       └── Views/
│   │           └── ChatView.swift
│   ├── Connection/              # Connection handling
│   │   └── Presentation/
│   │       └── Views/
│   │           └── NoConnectionView.swift
│   ├── Destruction/             # Self-destruction logic
│   ├── Home/                    # Main screen
│   │   └── Presentation/
│   │       ├── Components/
│   │       │   └── HomeTopBar.swift
│   │       ├── ViewModels/
│   │       │   └── HomeViewModel.swift
│   │       └── Views/
│   │           └── HomeView.swift
│   ├── Onboarding/             # Welcome flow
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
│   ├── RoomCreation/           # Room creation
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
│   ├── RoomJoin/               # Join existing rooms
│   │   └── Presentation/
│   │       └── Views/
│   │           └── RoomJoinView.swift
│   ├── Security/               # Security features
│   └── Settings/               # App settings
│       └── Presentation/
│           └── Views/
│               └── SettingsView.swift
└── Info.plist                  # iOS app configuration
```

---

## 🔧 Explanation of Protocols and Key Concepts

### What is a Protocol in Swift?

A **protocol** in Swift is like a **contract** or **template** that defines what functions and properties a class must have, but doesn't implement how they work. It's like defining the rules of a game without saying how to play it.

#### 📋 Simple Analogy:

Imagine you want to create different types of vehicles:
- A car, a motorcycle, a bicycle

They all have things in common: they can **accelerate**, **brake**, and **turn**. But each one implements them differently.

```swift
// This is the PROTOCOL (the contract)
protocol Vehicle {
    func accelerate()
    func brake()
    func turn(direction: String)
}

// These are the CLASSES that fulfill the contract
class Car: Vehicle {
    func accelerate() {
        print("Accelerating with gasoline engine")
    }
    
    func brake() {
        print("Braking with disc brakes")
    }
    
    func turn(direction: String) {
        print("Turning steering wheel to \(direction)")
    }
}

class Bicycle: Vehicle {
    func accelerate() {
        print("Pedaling faster")
    }
    
    func brake() {
        print("Squeezing brake levers")
    }
    
    func turn(direction: String) {
        print("Turning handlebars to \(direction)")
    }
}
```

### Protocols in Shadow

We use protocols in Shadow to organize the code and make it more maintainable:

#### 1. `SocketServiceProtocol`

**Why does it exist?**
So the app doesn't depend directly on a specific WebSocket implementation. We could switch from SocketIO to another library without having to modify the entire app.

**What does it define?**
```swift
protocol SocketServiceProtocol {
    var isConnected: Bool { get }           // Are we connected?
    var mySocketId: String? { get }          // What is my unique ID
    
    func connect(url: String)                // Connect to server
    func disconnect()                       // Disconnect
    
    func emit(_ event: SocketEmitEvent, _ data: [String: Any])  // Send events
    func on(_ event: SocketOnEvent, handler: @escaping ([Any]) -> Void)  // Listen for events
    func off(_ event: SocketOnEvent)        // Stop listening
    
    func decode<T: Decodable>(_ type: T.Type, from data: [Any]) -> T?  // Decode JSON
}
```

**Why is it useful?**
- **Testing**: We can create a fake version for tests
- **Flexibility**: If we want to use another library tomorrow, we only change the implementation
- **Organization**: Separates the "what" from the "how"

#### 2. `RoomRepositoryProtocol`

**Why does it exist?**
To separate business logic from UI. The View doesn't need to know how we get the rooms, only that it can get them.

**What does it define?**
```swift
protocol RoomRepositoryProtocol {
    var rooms: [RoomInfo] { get }            // Room list
    var isLoading: Bool { get }              // Are we loading?
    
    func loadMyRooms()                       // Load my rooms
    func startListening()                    // Start listening for changes
    func stopListening()                     // Stop listening
    
    func removeRoom(withCode code: String)   // Remove a room
    func insertRoom(_ room: RoomInfo, at index: Int)  // Add a room
}
```

---

## 🔄 Application Flow

### 1. Startup (`shadowApp.swift`)
```swift
@main
struct shadowApp: App {
    @State private var router = AppRouter()
    private let diContainer = DIContainer.shared
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(router)                    // Navigation system
                .environment(diContainer.socketService)  // WebSocket connection
                .environment(diContainer.roomRepository) // Room management
                .preferredColorScheme(ColorScheme.dark)
                .task {
                    // Connect to server when app starts
                    diContainer.socketService.connect(url: "http://localhost:3000")
                }
        }
    }
}
```

### 2. Navigation System (`AppRouter.swift`)
Controls which screen to show using state-based navigation:

- **Screens**: Main screens (.onboarding, .main)
- **Destinations**: Navigation destinations (.roomJoin, .chat, .settings)

### 3. Dependency Injection (`DIContainer.swift`)
Provides shared services to the entire application:
- `SocketService`: Manages WebSocket connection
- `RoomRepository`: Manages chat rooms

---

## 🔐 Security System

### End-to-End Encryption

Shadow uses ECDH (Elliptic Curve Diffie-Hellman) asymmetric cryptography:

1. **Key Generation**: Each user generates a key pair (public/private)
2. **Key Exchange**: Users exchange their public keys
3. **Shared Key**: A unique shared key is generated for each conversation
4. **Message Encryption**: Messages are encrypted with this shared key
5. **Self-Destruction**: Keys and messages are deleted when the room expires

### Security Events

- `securityAlert`: Security threat alerts
- `deadManCheckIn`: Dead man switch verifications
- `keyExchange`: Secure key exchange

---

## 🌐 WebSocket Communication

### Emitted Events (Client → Server)

```swift
enum SocketEmitEvent: String {
    case roomCreate      = "room:create"        // Create room
    case roomJoin        = "room:join"          // Join room
    case roomGetMyRooms  = "room:getMyRooms"    // Get my rooms
    case roomDestroy     = "room:destroy"       // Destroy room
    
    case messageSend     = "message:send"       // Send message
    case keyExchange     = "key:exchange"       // Key exchange
    
    case securityAlert   = "security:alert"     // Security alerts
    case deadManCheckIn  = "deadman:checkin"    // Active verification
    case deadManWarning  = "deadman:warning"    // Inactivity warning
    
    case typingStart     = "typing:start"       // User typing
    case typingStop      = "typing:stop"        // User stopped typing
}
```

### Received Events (Server → Client)

```swift
enum SocketOnEvent: String {
    case roomCreated      = "room:created"       // Room created
    case roomJoined       = "room:joined"        // Joined room
    case myRooms          = "room:myRooms"       // My rooms list
    case roomDestroyed    = "room:destroyed"     // Room destroyed
    case roomExpired      = "room:expired"       // Room expired
    
    case participantJoined = "participant:joined" // Someone joined
    case participantLeft   = "participant:left"   // Someone left
    
    case messageReceive   = "message:receive"     // Message received
    case messageSent      = "message:sent"       // Message sent
    
    case keyReceive       = "key:receive"        // Key received
    
    case securityAlert    = "security:alert"      // Security alert
    case deadManConfirmed = "deadman:confirmed"  // Verification confirmed
    case deadManWarning   = "deadman:warning"     // Warning received
    
    case typingStart      = "typing:start"       // Someone is typing
    case typingStop       = "typing:stop"        // Someone stopped typing
    
    case error            = "error"              // Server error
}
```

---

## 🎨 Design System

### Typography
Shadow uses a combination of modern fonts:
- **Syne**: For titles and highlighted elements
- **JetBrains Mono**: For code and technical elements
- **Space Grotesk**: For body text

### Colors
- **Dark**: Main theme for privacy
- **Accents**: Yellow (#E7FF47) and Cyan (#47FFE8) for important elements
- **Surfaces**: Subtle gradients for depth

### Components
- **AppButton**: Reusable button with multiple styles
- **ActiveRoomCard**: Card to display active rooms
- **HomeTopBar**: Custom top bar

---

## 📱 User Flow

### 1. Onboarding (First time)
- Step 1: Privacy and security explanation
- Step 2: Self-destruction demonstration
- Step 3: Basic usage tutorial

### 2. Main Screen
- List of active rooms with remaining time
- Button to create new room
- Button to join with code

### 3. Room Creation
- Lifetime configuration
- Alias setting
- Unique code generation

### 4. Chat
- Encrypted real-time messages
- Typing indicators
- Self-destruction countdown

---

## 🔧 Technologies Used

### Core Framework
- **SwiftUI**: Apple's declarative UI framework
- **Combine**: Reactive programming (implicit in @Observable)
- **Foundation**: iOS base classes

### Communication
- **SocketIO**: WebSocket communication library
- **JSON**: Data serialization

### Architecture
- **MVVM**: Model-View-ViewModel for separation of concerns
- **Dependency Injection**: For testing and modularity
- **Repository Pattern**: Data access abstraction
- **Observer Pattern**: For reactive UI updates

---

## 🚀 How to Run the Project

### Prerequisites
- Xcode 15.0 or higher
- iOS 17.0 or higher
- WebSocket server running at `http://localhost:3000`

### Steps
1. Clone the repository
2. Open `shadow.xcodeproj` in Xcode
3. Select an iOS device or simulator
4. Press Cmd+R to run

### Server Configuration
The project expects a WebSocket server with the following events:
- Connection at `http://localhost:3000`
- Support for all events defined in `SocketEvent.swift`

---

## 🧪 Testing

### UI Testing
- **shadowUITests**: Automated interface tests
- **shadowUITestsLaunchTests**: Launch tests

### Unit Testing
- **shadowTests**: Business logic unit tests

### Protocol Testing
Protocols facilitate testing by allowing mock implementations:
```swift
class MockSocketService: SocketServiceProtocol {
    var isConnected: Bool = false
    var mySocketId: String? = "test-id"
    
    // Fake implementations for testing
    func connect(url: String) { /* simulation */ }
    // ...
}
```

---

## 🔮 Future Features

### Planned
- [ ] Image and file encryption
- [ ] Customizable dark/light mode
- [ ] Encrypted push notifications
- [ ] Face ID identity verification
- [ ] Private rooms with password

### In Development
- [ ] Complete chat implementation
- [ ] Advanced self-destruction system
- [ ] Real-time security analysis

---

## 📄 License

This project is private and proprietary software. All rights reserved.

---

## 🤝 Contributing

This is a personal project developed by Frank Erick Santos Gonzales. For collaborations or questions, contact directly.

---

## 📞 Support

To report issues or request features:
1. Check the Testing section
2. Verify WebSocket server connection
3. Review logs in Xcode console

---

**Shadow - Where privacy is temporary, but security is eternal.** 🌑
