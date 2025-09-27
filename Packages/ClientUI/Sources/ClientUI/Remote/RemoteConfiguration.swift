import Foundation

public enum Transport: Sendable{
    case httpOnce
    case httpPolling(seconds: Int)
}

public struct RemoteConfiguration: Sendable {
    public var baseURL: URL
    public var initialPath: String
    public var transport: Transport
    /// Called at request time (pull fresh tokens from Keychain, etc)
    public var headersProvider: @Sendable () -> [String: String]
    /// Provide a custom session configuration if needed (cookies, caching, pinning, etc)
    public var sessionConfiguration: URLSessionConfiguration

    public init(
        baseURL: URL,
        initialPath: String = "/screen/home",
        transport: Transport = .httpOnce,
        headersProvider: @escaping @Sendable () -> [String: String] = { [:] },
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        self.baseURL = baseURL
        self.initialPath = initialPath
        self.transport = transport
        self.headersProvider = headersProvider
        self.sessionConfiguration = sessionConfiguration
    }
}

// MARK: - Convenience Functions

public extension RemoteConfiguration {

    var session: URLSession {
        URLSession(configuration: sessionConfiguration)
    }

    var url: URL {
        baseURL.appending(path: initialPath)
    }
}

public extension RemoteConfiguration {
    /// Dev convenience: localhost over HTTP with sane defaults.
    static func local(
        port: Int = 8080,
        path: String = "/screen/home",
        pollingSeconds: Int = 1
    ) -> RemoteConfiguration {
        RemoteConfiguration(
            baseURL: URL(string: "http://127.0.0.1:\(port)")!,
            initialPath: path,
            transport: .httpPolling(seconds: pollingSeconds)
        )
    }
}
