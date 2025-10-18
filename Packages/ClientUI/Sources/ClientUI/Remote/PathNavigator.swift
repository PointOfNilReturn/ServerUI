import Foundation
import SwiftUI
import ViewSchema
import Logging

/// Handles fetching view hierarchies from server paths.
///
/// Uses `RemoteConfiguration` to resolve and fetch JSON from absolute or relative paths.
/// Supports query parameters and custom headers.
@Observable
@MainActor
public final class PathNavigator {
    private let configuration: RemoteConfiguration
    private var currentPath: String
    private let logger = Logger(label: "com.serverui.pathnavigator")
    
    /// Creates a path navigator with the given configuration.
    ///
    /// - Parameters:
    ///   - configuration: Remote configuration containing base URL and headers.
    ///   - initialPath: The initial path (defaults to configuration's initial path).
    public init(configuration: RemoteConfiguration, initialPath: String? = nil) {
        self.configuration = configuration
        self.currentPath = initialPath ?? configuration.initialPath
    }
    
    /// Fetches a view hierarchy from the server.
    ///
    /// - Parameters:
    ///   - spec: The navigation link specification containing the path.
    ///   - viewInstanceId: A unique identifier for this view instance (for state scoping).
    /// - Returns: The fetched view hierarchy.
    /// - Throws: Network or decoding errors.
    public func fetch(_ spec: NavigationLinkSpec, viewInstanceId: String) async throws -> ViewHierarchy {
        let fullPath = try resolvePath(spec)
        let url = configuration.baseURL.appending(path: fullPath)
        
        logger.debug("Fetching view hierarchy", metadata: [
            "url": "\(url.absoluteString)",
            "viewInstanceId": "\(viewInstanceId)"
        ])
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add the view instance ID for state scoping
        request.setValue(viewInstanceId, forHTTPHeaderField: "X-View-Instance-ID")
        
        // Apply custom headers
        for (key, value) in configuration.headersProvider() {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let (data, _) = try await configuration.session.data(for: request)
            let envelope = try JSONDecoder().decode(ViewHierarchyEnvelope.self, from: data)
            logger.debug("Successfully fetched view hierarchy", metadata: ["url": "\(url.absoluteString)"])
            return envelope.viewHierarchy
        } catch {
            logger.error("Failed to fetch view hierarchy", metadata: [
                "url": "\(url.absoluteString)",
                "error": "\(error.localizedDescription)"
            ])
            throw error
        }
    }
    
    /// Resolves a navigation path to a full path string.
    ///
    /// - Parameter path: The navigation path.
    /// - Returns: The resolved path (including query parameters).
    public func resolvePath(_ path: ViewSchema.NavigationPath) -> String {
        switch path {
        case .path(let path):
            return path
        case .pathWithQuery(let path, let query):
            return buildPathWithQuery(path, query: query)
        }
    }
    
    /// Resolves a navigation link spec to a full path string.
    ///
    /// - Parameter spec: The navigation link specification.
    /// - Returns: The resolved path (including query parameters).
    /// - Throws: If the spec is not path-based.
    private func resolvePath(_ spec: NavigationLinkSpec) throws -> String {
        switch spec {
        case .embedded:
            throw PathNavigatorError.embeddedNavigation
            
        case .path(let path):
            return path
            
        case .pathWithQuery(let path, let query):
            return buildPathWithQuery(path, query: query)
        }
    }
    
    /// Builds a path with query parameters.
    ///
    /// - Parameters:
    ///   - path: The base path.
    ///   - query: Query parameters to append.
    /// - Returns: Path with query string (e.g., "/profile?id=123").
    private func buildPathWithQuery(_ path: String, query: [String: String]) -> String {
        guard !query.isEmpty else { return path }
        
        let queryString = query
            .map { key, value in
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
                return "\(encodedKey)=\(encodedValue)"
            }
            .joined(separator: "&")
        
        return "\(path)?\(queryString)"
    }
}

/// Errors that can occur during path navigation.
public enum PathNavigatorError: LocalizedError {
    case embeddedNavigation
    
    public var errorDescription: String? {
        switch self {
        case .embeddedNavigation:
            return "Cannot fetch embedded navigation - destination is already in the view hierarchy"
        }
    }
}

