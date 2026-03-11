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
│   │   ├── Repositories/
│   │   │   └── RoomRepository.swift
│   │   └── Services/
│   │       └── NotificationManager.swift
│   ├── Extensions/              # Swift extensions and utilities
│   │   └── NotificationCenter+RoomEvents.swift
│   └── Infrastructure/          # Technical infrastructure layer
│       ├── Crypto/              # Cryptographic services
│       │   └── CryptoService.swift
│       ├── DependencyInjection/
│       │   └── DIContainer.swift
│       ├── Network/             # Server communication
│       │   ├── SocketEvent.swift
│       │   ├── SocketService.swift
│       │   └── SocketServiceProtocol.swift
│       ├── Notifications/       # Notification system
│       │   ├── LocalNotificationService.swift
│       │   └── LocalNotificationServiceProtocol.swift
│       └── Storage/             # Secure local storage
│           ├── KeychainService.swift
│           ├── LocalStorageService.swift
│           └── StorageService.swift
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
│   │       ├── ViewModels/
│   │       │   └── ChatViewModel.swift
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
- `StorageService`: Unified storage facade
- `CryptoService`: E2EE cryptographic engine
- `NotificationManager`: Local notification management

---

## 🔐 Cryptographic Security System

### Secure Storage Architecture

#### 1. **KeychainService** - Sensitive Data
**Purpose**: Secure storage of cryptographic keys and sensitive data

**Features**:
- Native iOS encryption with Secure Enclave
- `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` - Only available when device is unlocked
- Secure persistence that survives app reinstalls

**Supported Key Types**:
```swift
enum KeychainKey {
    case privateKey              // User's ECDH key
    case roomKey(String)        // Room-specific AES-256 key
    case publicKey(String)       // Public key for server
}
```

**Main Methods**:
```swift
func save(_ data: Data, forKey key: KeychainKey) -> Bool
func load(forKey key: KeychainKey) -> Data?
func delete(forKey key: KeychainKey) -> Bool
```

#### 2. **LocalStorageService** - Non-Sensitive Data
**Purpose**: Storage of preferences and non-critical configurations

**Features**:
- Uses standard UserDefaults
- Unencrypted data (non-sensitive)
- Fast and efficient for preferences

**Stored Data**:
- Onboarding completion status
- UI preferences
- Temporary configurations

#### 3. **StorageService** - Unified Facade
**Purpose**: Single interface that automatically decides where to store each type of data

**Advantages**:
- Complete storage abstraction
- Automatic security decisions
- Consistent interface for entire app

### CryptoService - Cryptographic Engine

#### 1. **ECDH Key Management**
```swift
// Generate P256 private key
let privateKey = cryptoService.generatePrivateKey()

// Save securely to Keychain
cryptoService.savePrivateKey(privateKey)

// Load when needed
let loadedKey = cryptoService.loadPrivateKey()
```

#### 2. **Secure Key Exchange**
```swift
// Get public key to share
let publicKey = cryptoService.publicKeyFrom(privateKey)
let publicKeyData = cryptoService.encodePublicKey(publicKey)

// Receive public key from another participant
let receivedPublicKey = cryptoService.decodePublicKey(publicKeyData)!

// Generate shared secret (ECDH)
let sharedSecret = cryptoService.generateSharedSecret(
    privateKey: myPrivateKey,
    publicKey: receivedPublicKey
)
```

#### 3. **Room Keys System (AES-256)**
**Purpose**: Symmetric keys for encrypting messages within a room

**Complete Flow**:
1. **Generation**: `cryptoService.generateRoomKey()` - Creates AES-256
2. **Wrapping**: `cryptoService.wrapRoomKey(roomKey, sharedSecret)` - Encrypts room key with ECDH
3. **Unwrapping**: `cryptoService.unwrapRoomKey(wrappedKey, sharedSecret)` - Decrypts room key
4. **Encryption**: `cryptoService.encryptMessage(message, roomKey)` - Encrypts messages

#### 4. **Secure Cryptographic Salts**
```swift
private enum HKDFSalt {
    // For deriving wrapping key (wrap/unwrap room key via ECDH)
    static let keyWrapping = Data("shadow.e2ee.keyWrapping.v1".utf8)
    
    // For encrypt/decrypt direct with shared secret
    static let directEncrypt = Data("shadow.e2ee.directEncrypt.v1".utf8)
}
```

**Why fixed salts?**
- **Interoperability**: All devices use the same salt
- **Not secrets**: Salt is public context, not a key
- **Real security**: Comes from ECDH private key that never leaves the device

### Complete E2EE Flow in Shadow

#### 1. **Room Creation**
```swift
// 1. Generate ECDH key if not exists
let privateKey = cryptoService.loadPrivateKey() ?? cryptoService.generatePrivateKey()
cryptoService.savePrivateKey(privateKey)

// 2. Generate AES-256 room key for the room
let roomKey = cryptoService.generateRoomKey()

// 3. Save room key to Keychain
let roomKeyData = roomKey.withUnsafeBytes { Data($0) }
storageService.saveToKeychain(roomKeyData, forKey: .roomKey(roomCode))

// 4. Emit room creation event with public key
let publicKeyData = cryptoService.encodePublicKey(cryptoService.publicKeyFrom(privateKey))
socketService.emit("room:create", [
    "publicKey": publicKeyData.base64EncodedString()
])
```

#### 2. **Room Join**
```swift
// 1. Receive creator's public key
socketService.on("room:joined") { data in
    let creatorPublicKeyData = Data(base64Encoded: creatorPublicKeyString)!
    let creatorPublicKey = cryptoService.decodePublicKey(creatorPublicKeyData)!
    
    // 2. Generate ECDH shared secret
    let sharedSecret = cryptoService.generateSharedSecret(
        privateKey: myPrivateKey,
        publicKey: creatorPublicKey
    )!
    
    // 3. Receive encrypted room key (wrapped)
    let wrappedRoomKey = Data(base64Encoded: wrappedKeyString)!
    
    // 4. Decrypt room key with shared secret
    let roomKey = cryptoService.unwrapRoomKey(wrappedRoomKey, sharedSecret: sharedSecret)!
    
    // 5. Save room key for message encryption
    let roomKeyData = roomKey.withUnsafeBytes { Data($0) }
    storageService.saveToKeychain(roomKeyData, forKey: .roomKey(roomCode))
}
```

#### 3. **Message Send**
```swift
// 1. Load room key from Keychain
let roomKeyData = storageService.loadFromKeychain(forKey: .roomKey(roomCode))!
let roomKey = SymmetricKey(data: roomKeyData)

// 2. Encrypt message with room key
let messageData = message.data(using: .utf8)!
let encryptedMessage = cryptoService.encryptMessage(messageData, roomKey: roomKey)!

// 3. Send encrypted message
socketService.emit("message:send", [
    "roomCode": roomCode,
    "message": encryptedMessage.base64EncodedString()
])
```

#### 4. **Message Receive**
```swift
socketService.on("message:receive") { data in
    // 1. Decode encrypted message
    let encryptedMessage = Data(base64Encoded: encryptedString)!
    
    // 2. Load room key
    let roomKeyData = storageService.loadFromKeychain(forKey: .roomKey(roomCode))!
    let roomKey = SymmetricKey(data: roomKeyData)
    
    // 3. Decrypt message
    let decryptedMessage = cryptoService.decryptMessage(encryptedMessage, roomKey: roomKey)!
    let message = String(data: decryptedMessage, encoding: .utf8)!
    
    // 4. Display message in UI
    addMessageToChat(message)
}
```

### Security Events

- `securityAlert`: Security threat alerts
- `deadManCheckIn`: Dead man switch verifications
- `keyExchange`: Secure public key exchange

### Key Exchange Flow

#### 1. **`key:exchange` Event**
**Purpose**: Send public key to other room participants

**When to use**:
- When creating a room (creator shares their public key)
- When joining a room (new participant shares their public key)
- When a participant joins (everyone shares their public keys)

**Event structure**:
```swift
// Emit public key
socketService.emit("key:exchange", [
    "roomCode": "ABC123",
    "publicKey": "base64EncodedPublicKeyData",
    "participantAlias": "MyAlias"
])

// Receive public key from others
socketService.on("key:receive") { data in
    let roomCode = data[0] as? String ?? ""
    let publicKeyData = Data(base64Encoded: data[1] as? String ?? "")!
    let participantAlias = data[2] as? String ?? ""
    
    // Process received public key
    processReceivedPublicKey(from: participantAlias, publicKey: publicKeyData)
}
```

#### 2. **Complete Key Exchange Process**
```swift
// 1. When joining room, emit my public key
func joinRoom(roomCode: String) {
    // Generate my ECDH key if not exists
    let myPrivateKey = cryptoService.loadPrivateKey() ?? cryptoService.generatePrivateKey()
    cryptoService.savePrivateKey(myPrivateKey)
    
    // Get my public key
    let myPublicKey = cryptoService.publicKeyFrom(myPrivateKey)
    let publicKeyData = cryptoService.encodePublicKey(myPublicKey)
    
    // Emit to all participants
    socketService.emit("key:exchange", [
        "roomCode": roomCode,
        "publicKey": publicKeyData.base64EncodedString(),
        "participantAlias": userAlias
    ])
}

// 2. Receive public keys from other participants
socketService.on("key:receive") { data in
    guard let roomCode = data[0] as? String,
          let publicKeyString = data[1] as? String,
          let participantAlias = data[2] as? String else { return }
    
    let publicKeyData = Data(base64Encoded: publicKeyString)!
    let publicKey = cryptoService.decodePublicKey(publicKeyData)!
    
    // Generate shared secret with this participant
    let myPrivateKey = cryptoService.loadPrivateKey()!
    let sharedSecret = cryptoService.generateSharedSecret(
        privateKey: myPrivateKey,
        publicKey: publicKey
    )!
    
    // Save shared secret for this participant
    // NOTE: This enables 1-to-1 communication with each participant
    saveSharedSecret(for: participantAlias, secret: sharedSecret)
    
    // If I'm the creator, send encrypted room key
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

#### 3. **Additional Events for Key Management**

**`room:key:share`** - Share encrypted room key:
```swift
// Only room creator sends this
socketService.emit("room:key:share", [
    "roomCode": roomCode,
    "targetParticipant": "targetAlias",
    "wrappedRoomKey": "encryptedRoomKeyInBase64"
])
```

**`room:key:receive`** - Receive encrypted room key:
```swift
socketService.on("room:key:receive") { data in
    let wrappedRoomKey = Data(base64Encoded: data[0] as? String ?? "")!
    let senderAlias = data[1] as? String ?? ""
    
    // Decrypt room key with sender's shared secret
    let sharedSecret = getSharedSecret(for: senderAlias)!
    let roomKey = cryptoService.unwrapRoomKey(wrappedRoomKey, sharedSecret: sharedSecret)!
    
    // Save room key for sending/receiving messages
    saveRoomKey(roomKey, for: roomCode)
}
```

#### 4. **Complete Key Exchange Flow**
1. **Room Join**: Emit public key
2. **Reception**: Receive public keys from other participants
3. **Shared Secrets**: Generate shared secret with each participant
4. **Room Key Distribution**: Creator encrypts and shares room key
5. **Room Key Reception**: Participants decrypt and save room key
6. **Communication**: Use room key to encrypt messages

#### 5. **Key Exchange Scenarios in Chat**

## 🔄 **Scenario 1: Dynamic Room (2+ People, Variable Growth)**

### **Important: Not fixed 1-to-1 chat**
- **It's a room that can grow** from 2 to 10+ people
- Participants can join/leave dynamically
- Key exchange must handle real-time growth

### **Room Growth Flow**
```
Initial State: 2 people
┌─────────────────────────────────────┐
│ Alice (Creator)       Bob        │
│ 🔒🔓                 🔒🔓        │
│ SharedSecret🤫                     │
│ RoomKey🔑                         │
└─────────────────────────────────────┘

Carol joins (3rd person)
┌─────────────────────────────────────┐
│ Alice (Creator)  Bob    Carol   │
│ 🔒🔓           🔒🔓     🔒🔓│
│ 🤫              🤫         🤫   │
│ 🔑              🔑          🔑   │
└─────────────────────────────────────┘

David joins (4th person)
┌─────────────────────────────────────────────┐
│ Alice    Bob    Carol   David (New)    │
│ 🔒🔓    🔒🔓    🔒🔓    🔒🔓       │
│ 🤫        🤫        🤫        🤫           │
│ 🔑        🔑        🔑        🔑           │
└─────────────────────────────────────────────┘
```

### **Implementation for Dynamic Room**
```swift
class DynamicRoomKeyManager {
    private var participants: [String: ParticipantKeys] = [:]
    private var roomKey: SymmetricKey?
    private let roomCode: String
    private let creatorAlias: String
    
    // 1. START: Creator establishes room
    func initializeRoom(creatorAlias: String) {
        self.creatorAlias = creatorAlias
        
        // Creator generates their ECDH key
        let creatorKey = cryptoService.generatePrivateKey()
        cryptoService.savePrivateKey(creatorKey)
        
        // Creator generates initial room key
        let initialRoomKey = cryptoService.generateRoomKey()
        self.roomKey = initialRoomKey
        
        // Creator saves themselves as participant
        let creatorPublicKey = cryptoService.publicKeyFrom(creatorKey)
        participants[creatorAlias] = ParticipantKeys(
            alias: creatorAlias,
            publicKey: creatorPublicKey,
            sharedSecret: nil, // Creator doesn't need shared secret with themselves
            roomKey: initialRoomKey
        )
        
        // Emit creator's public key
        let publicKeyData = cryptoService.encodePublicKey(creatorPublicKey)
        socketService.emit("key:exchange", [
            "roomCode": roomCode,
            "publicKey": publicKeyData,
            "participantAlias": creatorAlias
        ])
    }
    
    // 2. NEW PARTICIPANT: Someone joins
    func onNewParticipantJoined(alias: String, publicKeyData: Data) {
        print("👋 New participant: \(alias)")
        
        // Decode new participant's public key
        let newParticipantPublicKey = cryptoService.decodePublicKey(publicKeyData)!
        
        // Each existing participant generates shared secret with new one
        for (existingAlias, existingParticipant) in participants {
            let myPrivateKey = cryptoService.loadPrivateKey()!
            
            let sharedSecret = cryptoService.generateSharedSecret(
                privateKey: myPrivateKey,
                publicKey: newParticipantPublicKey
            )!
            
            // Save shared secret for communication with this participant
            participants[existingAlias]?.sharedSecretWithNew = sharedSecret
        }
        
        // New participant generates shared secrets with all existing ones
        let newPrivateKey = cryptoService.generatePrivateKey()
        let sharedSecretsForNew: [String: SharedSecret] = [:]
        
        for (existingAlias, existingParticipant) in participants {
            let sharedSecret = cryptoService.generateSharedSecret(
                privateKey: newPrivateKey,
                publicKey: existingParticipant.publicKey
            )!
            sharedSecretsForNew[existingAlias] = sharedSecret
        }
        
        // Add new participant to system
        participants[alias] = ParticipantKeys(
            alias: alias,
            publicKey: newParticipantPublicKey,
            sharedSecretWithExisting: sharedSecretsForNew,
            roomKey: nil // Doesn't have room key yet
        )
        
        // Creator sends room key to new participant
        if roomKey != nil {
            sendRoomKeyToParticipant(alias)
        }
        
        // Notify everyone about new participant
        broadcastParticipantUpdate()
    }
    
    // 3. SEND ROOM KEY: Creator shares with new participant
    private func sendRoomKeyToParticipant(_ participantAlias: String) {
        guard let roomKey = roomKey,
              let participant = participants[participantAlias] else { return }
        
        // Use shared secret between creator and this participant
        let sharedSecret = participant.sharedSecretWithCreator ?? generateSharedSecretWithCreator(participant.publicKey)
        
        let wrappedRoomKey = cryptoService.wrapRoomKey(roomKey, sharedSecret: sharedSecret)
        
        socketService.emit("room:key:share", [
            "roomCode": roomCode,
            "targetParticipant": participantAlias,
            "wrappedRoomKey": wrappedRoomKey.base64EncodedString(),
            "senderAlias": creatorAlias
        ])
        
        print("🔑 Room key sent to \(participantAlias)")
    }
    
    // 4. PARTICIPANT RECEIVES ROOM KEY
    func onRoomKeyReceived(wrappedKeyData: Data, from senderAlias: String) {
        guard let participant = participants[senderAlias] else { return }
        
        // Use shared secret with whoever sent the room key
        let sharedSecret = participant.sharedSecretWithSender
        
        let roomKey = cryptoService.unwrapRoomKey(wrappedKeyData, sharedSecret: sharedSecret)
        
        // Save room key for this participant
        participants[senderAlias]?.roomKey = roomKey
        
        print("🔓 \(senderAlias) received room key. Ready to chat!")
        
        // If first participant to receive room key, notify everyone
        if countParticipantsWithRoomKey() == 1 {
            broadcastRoomReady()
        }
    }
    
    // 5. MESSAGES: Anyone can send to all
    func sendMessageToAll(_ message: String) {
        guard let roomKey = roomKey else {
            print("❌ Room key not available yet")
            return
        }
        
        let messageData = message.data(using: .utf8)!
        let encryptedMessage = cryptoService.encryptMessage(messageData, roomKey: roomKey)!
        
        // Send same encrypted message to everyone
        for participantAlias in participants.keys {
            socketService.emit("message:send", [
                "roomCode": roomCode,
                "targetParticipant": participantAlias,
                "message": encryptedMessage.base64EncodedString(),
                "senderAlias": getCurrentUserAlias()
            ])
        }
        
        print("📨 Message sent to \(participants.count) participants")
    }
    
    // 6. PARTICIPANT LEAVES: Key cleanup
    func onParticipantLeft(alias: String) {
        participants.removeValue(forKey: alias)
        
        print("👋 \(alias) left the room")
        
        // Optional: Rotate room key for security
        if shouldRotateRoomKeyOnLeave() {
            rotateRoomKeyForRemainingParticipants()
        }
        
        // Notify others
        broadcastParticipantUpdate()
    }
    
    // 7. UTILITIES
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
            "message": "Room is ready for E2EE chat!"
        ])
    }
}

// Enhanced structure for dynamic participants
struct ParticipantKeys {
    let alias: String
    let publicKey: P256.KeyAgreement.PublicKey
    
    // For creator: shared secrets with each participant
    var sharedSecretWithParticipant: [String: SharedSecret] = [:]
    
    // For participants: shared secret with creator
    var sharedSecretWithCreator: SharedSecret?
    
    // For new participants: shared secrets with existing ones
    var sharedSecretWithExisting: [String: SharedSecret] = [:]
    var sharedSecretWithSender: SharedSecret?
    
    // Room key (when received)
    var roomKey: SymmetricKey?
}
```

### **Visual Flow of Dynamic Room**
```
🏠 Room "ABC123" - Created by Alice

┌─ START ─────────────────────┐
│ Alice creates room              │
│ Generates: 🔒🔓 + 🔑        │
│ Emits: key:exchange          │
└────────────────────────────────┘
          │
          ▼
┌─ Bob joins ──────────────────┐
│ Bob generates 🔒🔓              │
│ Emits: key:exchange          │
│ Receives: 🔓 from Alice         │
│ Calculates: 🤫 (Alice+Bob)     │
└────────────────────────────────┘
          │
          ▼
┌─ Alice sends Room Key ────────┐
│ Encrypts 🔑 with 🤫           │
│ Sends: room:key:share        │
│ Bob receives and decrypts 🔑     │
└────────────────────────────────┘
          │
          ▼
┌─ Carol joins ─────────────────┐
│ Carol generates 🔒🔓             │
│ Emits: key:exchange          │
│ Everyone receives 🔓 from Carol   │
│ Everyone calculates 🤫 with Carol │
│ Alice sends 🔑 to Carol       │
└────────────────────────────────┘
          │
          ▼
┌─ David joins ─────────────────┐
│ David generates 🔒🔓             │
│ Emits: key:exchange          │
│ Everyone receives 🔓 from David   │
│ Everyone calculates 🤫 with David │
│ Alice sends 🔑 to David       │
└────────────────────────────────┘
          │
          ▼
┌─ FULL E2EE CHAT ────────────┐
│ Everyone has 🔑               │
│ Everyone can encrypt/decrypt     │
│ Server cannot read ANYTHING      │
│ Room ready for 10+ people       │
└────────────────────────────────┘
```

### **Real Use Cases**

#### **Team Meeting (5-10 people)**
```
1. Manager creates room and shares code
2. Team members join one by one
3. Each new member receives room key from manager
4. Everyone can collaborate with E2EE
5. If someone leaves, keys are cleaned automatically
```

#### **Virtual Class (20+ students)**
```
1. Teacher creates room and shares code
2. Students join dynamically
3. Each student gets room key when joining
4. Everyone can participate with total privacy
5. Server cannot see class content
```

#### **Public Event (50+ people)**
```
1. Organizer creates massive room
2. Attendees join continuously
3. System scales automatically
4. Room key distributed to each new participant
5. Private chat even in public event
```

### **Advantages of This Approach**

✅ **Scalability**: Supports 2 to 50+ participants  
✅ **Security**: Every communication is E2EE  
✅ **Flexibility**: People join/leave dynamically  
✅ **Simplicity**: 1 room key for everyone  
✅ **Zero Knowledge**: Server cannot decrypt  

⚠️ **Complexity**: Managing multiple shared secrets  
⚠️ **Synchronization**: Requires precise coordination

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
    case keyExchange     = "key:exchange"       // Public key exchange
    case roomKeyShare    = "room:key:share"     // Share encrypted room key
    
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
    
    case keyReceive       = "key:receive"        // Public key received
    case roomKeyReceive  = "room:key:receive"   // Encrypted room key received
    
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
