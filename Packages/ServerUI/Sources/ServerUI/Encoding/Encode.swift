import Foundation
import ViewSchema

// MARK: - Encoding Engine

/// The core encoding engine that transforms view hierarchies into JSON-serializable structures.
///
/// The `Engine` provides the internal implementation for converting ServerUI views into
/// `ViewHierarchy` and `ViewNode` structures that can be JSON-encoded and sent to clients.
///
/// ## Architecture Overview
///
/// The encoding process consists of two main phases:
///
/// 1. **View Decomposition**: Recursively break down the view tree using the `body` property
///    until reaching primitive views (Text, VStack, HStack, etc.)
///
/// 2. **Node Construction**: Convert each primitive view into a `ViewNode` with:
///    - A `ViewType` enum case identifying the view
///    - An array of child `ViewNode`s (for containers)
///    - An array of `Modifier`s to apply
///
/// ## Type Erasure Challenge
///
/// Because views are strongly-typed generics (e.g., `VStack<TupleView<Text, Text>>`), the
/// encoding engine can't use simple type switches. Instead, it uses **protocol-based type erasure**:
///
/// - `VStackProtocol`, `HStackProtocol` - Extract container specs and content
/// - `TupleViewProtocol` - Extract children from parameter pack tuples
/// - `ModifiedContentProtocol` - Extract modifiers from wrapper views
/// - `_ConditionalContentProtocol`, `_ArrayViewProtocol` - Handle control flow
///
/// This allows the engine to work with `any View` while still accessing type-specific properties.
///
/// ## Recursion Strategy
///
/// The engine uses two mutually recursive functions:
/// - `viewNode(from:)` - Converts a view to a node (may recurse via `body`)
/// - `collectChildren(from:)` - Extracts children from container content
///
/// - SeeAlso: `ServerUIJSON.encode(_:)` for the public API
enum Engine {
    /// Converts a root view into a complete view hierarchy.
    ///
    /// - Parameter view: The root view to encode.
    /// - Returns: A `ViewHierarchy` containing the encoded view tree.
    static func viewHierarchy<Content: View>(from view: Content) -> ViewHierarchy {
        ViewHierarchy(root: viewNode(from: view))
    }

    /// Recursively converts a view into a view node.
    ///
    /// This is the core of the encoding engine. It handles different view types through
    /// a combination of protocols and recursive decomposition.
    ///
    /// ## Processing Order
    ///
    /// 1. **ModifiedContent** - If present, unwrap and accumulate modifiers
    /// 2. **Primitive Leaf Views** - Text, EmptyView → Create terminal nodes
    /// 3. **Container Views** - VStack, HStack → Create nodes with children
    /// 4. **Custom Views** - Recurse into their `body` property
    ///
    /// ## Modifier Accumulation
    ///
    /// When encountering `ModifiedContent`, the engine:
    /// 1. Extracts the inner content and modifier
    /// 2. Recursively encodes the inner content
    /// 3. Appends the modifier to the resulting node
    ///
    /// This allows modifiers to accumulate on the underlying primitive view:
    /// ```swift
    /// Text("Hello").font(.title).foregroundColor(.blue)
    /// // Becomes: ViewNode(type: .text, modifiers: [.font(.title), .foregroundColor(.blue)])
    /// ```
    ///
    /// ## Custom View Recursion
    ///
    /// For user-defined views that conform to `View`, the engine calls `.body` to
    /// decompose them into primitives. This continues recursively until only primitive
    /// views remain.
    ///
    /// - Parameter view: The view to encode.
    /// - Returns: A `ViewNode` representing the encoded view.
    static func viewNode<Content: View>(from view: Content) -> ViewNode {
        // Check for modified content first to accumulate modifiers
        if let modified = view as? any _ModifiedContentProtocol {
            let (content, modifier) = modified.extractModifier()
            var node = viewNode(from: content)
            node.modifiers.append(modifier)
            return node
        }
        
        // Try to match concrete view types
        switch view {
        case let text as Text:
            return ViewNode(type: .text(text.spec))
            
        case is EmptyView:
            return ViewNode(type: .unknown)
            
        default:
            // Check for VStack using protocol
            if let vstack = view as? any _VStackProtocol {
                let (spec, content) = vstack.extractVStack()
                return ViewNode(
                    type: .vstack(spec),
                    children: collectChildren(from: content)
                )
            }
            
            // Check for HStack using protocol
            if let hstack = view as? any _HStackProtocol {
                let (spec, content) = hstack.extractHStack()
                return ViewNode(
                    type: .hstack(spec),
                    children: collectChildren(from: content)
                )
            }
            
            // Check for List using protocol
            if let list = view as? any _ListProtocol {
                let (spec, content) = list.extractList()
                return ViewNode(
                    type: .list(spec),
                    children: collectChildren(from: content)
                )
            }
            
            // Check for ScrollView using protocol
            if let scrollView = view as? any _ScrollViewProtocol {
                let (spec, content) = scrollView.extractScrollView()
                return ViewNode(
                    type: .scrollView(spec),
                    children: collectChildren(from: content)
                )
            }
            
            // Check for NavigationStack using protocol
            if let navStack = view as? any _NavigationStackProtocol {
                let (spec, content) = navStack.extractNavigationStack()
                return ViewNode(
                    type: .navigationStack(spec),
                    children: collectChildren(from: content)
                )
            }
            
            // Check for NavigationLink using protocol
            if let navLink = view as? any _NavigationLinkProtocol {
                let (spec, label, destination) = navLink.extractNavigationLink()
                
                // For path-based navigation, only encode the label
                // For embedded navigation, encode both label and destination
                let children: [ViewNode]
                switch spec {
                case .embedded:
                    children = [viewNode(from: label), viewNode(from: destination)]
                case .absolutePath, .relativePath, .absolutePathWithQuery, .relativePathWithQuery:
                    children = [viewNode(from: label)]
                }
                
                return ViewNode(
                    type: .navigationLink(spec),
                    children: children
                )
            }
            
            // Check for Button using protocol
            if let button = view as? any _ButtonProtocol {
                let (label, actionId) = button.extractButton()
                return ViewNode(
                    type: .button(ButtonSpec(actionId: actionId)),
                    children: [viewNode(from: label)]
                )
            }
            
            // Check for TextField using protocol
            if let textField = view as? any _TextFieldProtocol {
                let (prompt, stateKey, currentValue) = textField.extractTextField()
                return ViewNode(
                    type: .textField(TextFieldSpec(prompt: prompt, stateKey: stateKey, currentValue: currentValue))
                )
            }
            
            // For custom views and wrappers, recurse into their body
            return viewNode(from: view.body)
        }
    }
    
    /// Extracts and encodes child views from container content.
    ///
    /// This function handles the various types that can appear as content in container views
    /// (like `VStack` and `HStack`). The content type depends on what the `@ViewBuilder`
    /// produced when the container was created.
    ///
    /// ## Supported Content Types
    ///
    /// - **TupleView** - Multiple children (2+) → Extracts each via parameter pack iteration
    /// - **Single View** - One child → Returns array with single encoded node
    /// - **EmptyView** - No children → Returns empty array
    /// - **ConditionalContent** - if/else result → Extracts and encodes the active branch
    /// - **ArrayView** - for loop result → Extracts and encodes all elements
    /// - **Optional** - if without else → Encodes the view if present, empty if nil
    /// - **ModifiedContent** - Unwraps to access actual content
    ///
    /// ## Example Flow
    ///
    /// ```swift
    /// VStack {
    ///     Text("A")
    ///     Text("B")
    ///     Text("C")
    /// }
    /// ```
    ///
    /// 1. VStack's content type is `TupleView<Text, Text, Text>`
    /// 2. `collectChildren` detects `TupleViewProtocol`
    /// 3. Calls `extractChildren()` → `[Text("A"), Text("B"), Text("C")]`
    /// 4. Maps each to `viewNode(from:)` → `[ViewNode, ViewNode, ViewNode]`
    ///
    /// - Parameter view: The container's content view (often a `TupleView` or single view).
    /// - Returns: An array of `ViewNode`s representing the children.
    static func collectChildren<Content: View>(from view: Content) -> [ViewNode] {
        // Check for TupleView first before type erasure
        if let tuple = view as? any _TupleViewProtocol {
            return tuple.extractChildren().map { viewNode(from: $0) }
        }
        
        switch view {
        case is EmptyView:
            return []
            
        case let conditional as any _ConditionalContentProtocol:
            return conditional.extractChildren().map { viewNode(from: $0) }
            
        case let array as any _ArrayViewProtocol:
            return array.extractViews().map { viewNode(from: $0) }
            
        case let optional as (any View)?:
            if let optional = optional {
                return [viewNode(from: optional)]
            } else {
                return []
            }
            
        default:
            // Single view case - use viewNode to properly handle ModifiedContent
            // This ensures modifiers are preserved on single children (e.g., List.navigationTitle())
            return [viewNode(from: view)]
        }
    }
}

// MARK: - Helper Protocols for Type Erasure

/// Protocol for extracting children from `TupleView` without knowing parameter pack types.
///
/// Because `TupleView` uses variadic generics (`TupleView<each Content: View>`), the encoding
/// engine cannot directly access its contents through simple casting. This protocol provides
/// a type-erased interface to extract the children as an array.
///
/// ## Why This Is Needed
///
/// Without this protocol:
/// ```swift
/// // ❌ Cannot cast because we don't know the specific types
/// if let tuple = view as? TupleView<???> {
///     // What types go here?
/// }
/// ```
///
/// With this protocol:
/// ```swift
/// // ✅ Works with any TupleView regardless of child types
/// if let tuple = view as? any _TupleViewProtocol {
///     let children = tuple.extractChildren() // [any View]
/// }
/// ```
///
/// - Note: The underscore prefix indicates this is an implementation detail that users
///   should not directly interact with.
/// - SeeAlso: `TupleView.extractChildren()`
public protocol _TupleViewProtocol {
    /// Extracts all child views as type-erased views.
    func extractChildren() -> [any View]
}

/// Protocol for extracting the active branch from conditional content (if-else).
///
/// Provides type-erased access to `_ConditionalContent` views.
///
/// - Note: The underscore prefix indicates this is an implementation detail that users
///   should not directly interact with.
/// - SeeAlso: `_ConditionalContent.extractChildren()`
public protocol _ConditionalContentProtocol {
    /// Extracts the active branch (either true or false) as a type-erased view.
    func extractChildren() -> [any View]
}

/// Protocol for extracting views from array content (for loops).
///
/// Provides type-erased access to `_ArrayView` instances.
///
/// - Note: The underscore prefix indicates this is an implementation detail that users
///   should not directly interact with.
/// - SeeAlso: `_ArrayView.extractViews()`
public protocol _ArrayViewProtocol {
    /// Extracts all views from the array.
    func extractViews() -> [any View]
}

/// Protocol for extracting modifiers and content from `ModifiedContent`.
///
/// Allows the encoding engine to unwrap modifier wrappers and accumulate them
/// on the underlying view node.
///
/// - Note: The underscore prefix indicates this is an implementation detail that users
///   should not directly interact with.
/// - SeeAlso: `ModifiedContent.extractModifier()`
public protocol _ModifiedContentProtocol {
    /// Extracts the underlying content and the modifier to apply.
    func extractModifier() -> (content: any View, modifier: Modifier)
}

/// Protocol for extracting specifications and content from `VStack`.
///
/// Provides type-erased access to VStack properties.
///
/// - Note: The underscore prefix indicates this is an implementation detail that users
///   should not directly interact with.
/// - SeeAlso: `VStack.extractVStack()`
public protocol _VStackProtocol {
    /// Extracts the VStack specification and its type-erased content.
    func extractVStack() -> (spec: VStackSpec, content: any View)
}

/// Protocol for extracting specifications and content from `HStack`.
///
/// Provides type-erased access to HStack properties.
///
/// - Note: The underscore prefix indicates this is an implementation detail that users
///   should not directly interact with.
/// - SeeAlso: `HStack.extractHStack()`
public protocol _HStackProtocol {
    /// Extracts the HStack specification and its type-erased content.
    func extractHStack() -> (spec: HStackSpec, content: any View)
}

/// Protocol for extracting specifications and content from `NavigationStack`.
///
/// Provides type-erased access to NavigationStack properties.
///
/// - Note: The underscore prefix indicates this is an implementation detail that users
///   should not directly interact with.
/// - SeeAlso: `NavigationStack.extractNavigationStack()`
public protocol _NavigationStackProtocol {
    /// Extracts the NavigationStack specification and its type-erased content.
    func extractNavigationStack() -> (spec: NavigationStackSpec, content: any View)
}

/// Protocol for extracting specifications, label, and destination from `NavigationLink`.
///
/// Provides type-erased access to NavigationLink properties.
///
/// - Note: The underscore prefix indicates this is an implementation detail that users
///   should not directly interact with.
/// - SeeAlso: `NavigationLink.extractNavigationLink()`
public protocol _NavigationLinkProtocol {
    /// Extracts the NavigationLink specification, label, and destination views.
    func extractNavigationLink() -> (spec: NavigationLinkSpec, label: any View, destination: any View)
}

/// Protocol for extracting label and action ID from `Button`.
///
/// Provides type-erased access to Button properties.
///
/// - Note: The underscore prefix indicates this is an implementation detail that users
///   should not directly interact with.
/// - SeeAlso: `Button.extractButton()`
public protocol _ButtonProtocol {
    /// Extracts the Button's label view and action ID.
    func extractButton() -> (label: any View, actionId: ActionID)
}

/// Protocol for extracting prompt and state key from `TextField`.
///
/// Provides type-erased access to TextField properties.
///
/// - Note: The underscore prefix indicates this is an implementation detail that users
///   should not directly interact with.
/// - SeeAlso: `TextField.extractTextField()`
public protocol _TextFieldProtocol {
    /// Extracts the TextField's prompt, state key, and current value.
    func extractTextField() -> (prompt: String, stateKey: String, currentValue: String)
}

/// Protocol for extracting spec and content from `List`.
///
/// Provides type-erased access to List properties.
///
/// - Note: The underscore prefix indicates this is an implementation detail that users
///   should not directly interact with.
/// - SeeAlso: `List.extractList()`
public protocol _ListProtocol {
    /// Extracts the List's spec and content.
    func extractList() -> (spec: ListSpec, content: any View)
}

/// Protocol for extracting spec and content from `ScrollView`.
///
/// Provides type-erased access to ScrollView properties.
///
/// - Note: The underscore prefix indicates this is an implementation detail that users
///   should not directly interact with.
/// - SeeAlso: `ScrollView.extractScrollView()`
public protocol _ScrollViewProtocol {
    /// Extracts the ScrollView's spec and content.
    func extractScrollView() -> (spec: ScrollViewSpec, content: any View)
}

// MARK: - Public Encoding API

/// Public API for encoding ServerUI views into JSON.
///
/// `ServerUIJSON` provides the main entry point for converting view hierarchies into
/// JSON data that can be sent to clients over HTTP or WebSockets.
///
/// ## Usage
///
/// ```swift
/// struct MyView: View {
///     var body: some View {
///         VStack {
///             Text("Hello")
///             Text("World")
///         }
///     }
/// }
///
/// let jsonData = try ServerUIJSON.encode(MyView())
/// // Send jsonData to client...
/// ```
///
/// ## JSON Structure
///
/// The encoded JSON follows this structure:
/// ```json
/// {
///   "schemaVersion": 1,
///   "viewHierarchy": {
///     "root": {
///       "type": { "vstack": { ... } },
///       "children": [ ... ],
///       "modifiers": [ ... ]
///     }
///   }
/// }
/// ```
///
/// ## Schema Versioning
///
/// The `schemaVersion` field allows clients to handle breaking changes gracefully.
/// Increment this version when making incompatible changes to the view schema.
///
/// ## Error Handling
///
/// Encoding can fail if:
/// - Custom views have infinite recursion in their `body`
/// - Views contain non-encodable types (shouldn't happen with standard ServerUI types)
///
/// - SeeAlso: `ViewHierarchyEnvelope`, `ViewHierarchy`, `ViewNode`
public enum ServerUIJSON {
    /// Encodes a view hierarchy into JSON data.
    ///
    /// This method recursively traverses the view tree, converting each view into a `ViewNode`
    /// and serializing the result as pretty-printed JSON.
    ///
    /// - Parameters:
    ///   - root: The root view to encode.
    ///   - schemaVersion: The schema version to include in the envelope. Defaults to 1.
    /// - Returns: JSON-encoded data representing the view hierarchy.
    /// - Throws: `EncodingError` if the view hierarchy cannot be serialized.
    public static func encode<Content: View>(_ root: Content, schemaVersion: Int = 1) throws -> Data {
        let viewHierarchy = Engine.viewHierarchy(from: root)
        let viewHierarchyEnvelope = ViewHierarchyEnvelope(
            schemaVersion: schemaVersion,
            viewHierarchy: viewHierarchy
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(viewHierarchyEnvelope)
    }
}
