# Remote Configuration

Configure how your app connects to the server.

## Overview

``RemoteConfiguration`` controls all aspects of the client-server connection: base URL, paths, headers, polling behavior, and network session configuration.

## Basic Configuration

Create a configuration with required parameters:

```swift
let config = RemoteConfiguration(
    baseURL: URL(string: "https://api.example.com")!,
    initialPath: "/screen/home"
)
```

## Full Configuration

All available options:

```swift
let config = RemoteConfiguration(
    baseURL: URL(string: "https://api.example.com")!,
    initialPath: "/screen/dashboard",
    transport: .httpPolling(seconds: 10),
    headersProvider: {
        ["Authorization": "Bearer \(token)"]
    },
    sessionConfiguration: .default
)
```

## Base URL

The root URL for all requests:

```swift
baseURL: URL(string: "https://api.example.com")!
```

Paths are appended to this base. For example, with initialPath `/screen/home`, the full URL becomes `https://api.example.com/screen/home`.

## Initial Path

The first screen to load:

```swift
initialPath: "/screen/home"  // Default
```

This is fetched immediately when ``RemoteView`` appears.

## Transport

Control update frequency:

### HTTP Once (Default)
Fetch once, never update:
```swift
transport: .httpOnce
```

Best for: Static content, single-screen apps

### HTTP Polling
Continuously poll for updates:
```swift
transport: .httpPolling(seconds: 5)
```

Best for: Real-time dashboards, live data

The polling runs in the background while the view is visible.

## Headers Provider

Provide dynamic headers for each request:

```swift
headersProvider: {
    [
        "Authorization": "Bearer \(KeychainManager.getToken())",
        "X-Session-ID": "\(SessionManager.currentSession)",
        "X-App-Version": Bundle.main.appVersion
    ]
}
```

### Why Use a Closure?

The closure is called for **every request**, allowing you to:
- Fetch fresh auth tokens
- Include dynamic values
- Update headers without recreating the configuration

## Session Configuration

Customize URLSession behavior:

```swift
var sessionConfig = URLSessionConfiguration.default
sessionConfig.timeoutIntervalForRequest = 30
sessionConfig.httpAdditionalHeaders = ["User-Agent": "MyApp/1.0"]

let config = RemoteConfiguration(
    baseURL: yourURL,
    sessionConfiguration: sessionConfig
)
```

Useful for:
- Custom timeouts
- Certificate pinning
- Cookie management
- Caching policies

## Convenience Initializers

### Local Development

Quick setup for local testing:

```swift
RemoteConfiguration.local()  // http://127.0.0.1:8080/screen/home
```

With custom port:
```swift
RemoteConfiguration.local(port: 3000, path: "/screen/login")
```

With polling:
```swift
RemoteConfiguration.local(pollingSeconds: 2)
```

## Best Practices

### Security

✅ **Do:**
- Use HTTPS in production
- Implement certificate pinning for sensitive apps
- Rotate tokens regularly
- Use `headersProvider` for dynamic tokens

❌ **Don't:**
- Hardcode tokens in the app
- Use HTTP in production
- Store sensitive data in URL query parameters

### Performance

✅ **Do:**
- Use `.httpOnce` for static content
- Set reasonable polling intervals (5-10 seconds)
- Implement caching in your session configuration

❌ **Don't:**
- Poll more frequently than needed
- Forget to handle network errors
- Ignore battery impact of constant polling

### Error Handling

``RemoteView`` handles errors automatically, but you can monitor them:

```swift
// Errors are displayed to the user with a retry button
// Logging is automatic via swift-log
```

## Examples

### Production App

```swift
let config = RemoteConfiguration(
    baseURL: URL(string: "https://api.myapp.com")!,
    initialPath: "/screen/\(userRole)/dashboard",
    transport: .httpPolling(seconds: 30),
    headersProvider: {
        [
            "Authorization": "Bearer \(AuthManager.shared.token)",
            "X-Device-ID": UIDevice.current.identifierForVendor?.uuidString ?? ""
        ]
    }
)
```

### Development

```swift
#if DEBUG
let config = RemoteConfiguration.local(pollingSeconds: 1)
#else
let config = RemoteConfiguration(
    baseURL: URL(string: "https://api.myapp.com")!,
    initialPath: "/screen/home"
)
#endif
```

## See Also

- ``RemoteConfiguration``
- ``Transport``
- ``RemoteView``
- <doc:GettingStarted>

