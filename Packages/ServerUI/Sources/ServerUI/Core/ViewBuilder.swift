// MARK: - TupleView

/// A container view that holds multiple child views using Swift parameter packs.
///
/// `TupleView` is created automatically by `@ViewBuilder` when multiple views are specified
/// in a view builder closure. It uses Swift's variadic generics (parameter packs) to support
/// an unlimited number of children without requiring fixed overloads.
///
/// ## Parameter Packs
///
/// Unlike SwiftUI which uses 2-10 explicit overloads, ServerUI leverages Swift 5.9+ parameter packs:
///
/// ```swift
/// VStack {
///     Text("One")
///     Text("Two")
///     Text("Three")
///     // ... unlimited children supported!
/// }
/// // Results in: TupleView<Text, Text, Text>
/// ```
///
/// ## Encoding
///
/// During JSON encoding, `TupleView` conforms to `_TupleViewProtocol` which allows the encoding
/// engine to extract its children as an array of type-erased views for recursive processing.
///
/// - Note: This is an internal implementation detail. Users typically don't interact with
///   `TupleView` directly—it's created automatically by `@ViewBuilder`.
public struct TupleView<each Content: View>: View, _TupleViewProtocol {
    /// The tuple of child views, stored using a parameter pack.
    let content: (repeat each Content)
    
    /// Creates a tuple view with the given child views.
    ///
    /// - Parameter content: A variadic parameter pack of views to be held by this tuple view.
    public init(_ content: repeat each Content) {
        self.content = (repeat each content)
    }
    
    /// TupleView is a primitive container, so its body is EmptyView.
    public var body: EmptyView { EmptyView() }
    
    /// Extracts all child views as a type-erased array for encoding.
    ///
    /// This method uses parameter pack iteration to convert the strongly-typed tuple
    /// into an array of `any View`, allowing the encoding engine to process each child
    /// recursively without knowing the exact types at compile time.
    ///
    /// - Returns: An array containing all child views as type-erased `View` instances.
    public func extractChildren() -> [any View] {
        var children: [any View] = []
        repeat children.append(each content)
        return children
    }
}

// MARK: - ViewBuilder

/// A result builder that constructs views from multi-statement closures.
///
/// `ViewBuilder` enables the declarative DSL syntax familiar to SwiftUI developers, allowing
/// you to compose views using natural, readable code structures. It's applied automatically
/// to closure parameters in view initializers.
///
/// ## Usage
///
/// You typically don't use `ViewBuilder` directly. Instead, it's applied via the `@ViewBuilder`
/// attribute on closure parameters:
///
/// ```swift
/// public struct VStack<Content: View>: View {
///     public init(
///         alignment: HorizontalAlignmentSpec = .center,
///         spacing: Double? = nil,
///         @ViewBuilder content: () -> Content  // <- Applied here
///     ) { ... }
/// }
/// ```
///
/// This allows users to write:
///
/// ```swift
/// VStack {
///     Text("Line 1")
///     Text("Line 2")
///     if showDetails {
///         Text("Details")
///     }
/// }
/// ```
///
/// ## Implementation with Parameter Packs
///
/// Unlike SwiftUI's `ViewBuilder` which requires 2-10 explicit overloads, ServerUI's implementation
/// leverages Swift 5.9's parameter packs for unlimited children:
///
/// - **0 children**: Returns `EmptyView`
/// - **1 child**: Returns the child view directly
/// - **2 children**: Explicit overload returning `TupleView<C0, C1>`
/// - **3+ children**: Parameter pack overload returning `TupleView<C0, C1, C2, repeat each Content>`
///
/// The explicit 2-child and 3+ child overloads are necessary because Swift's overload resolution
/// would otherwise be ambiguous—parameter packs can match any number of arguments including 0, 1, or many.
///
/// ## Control Flow Support
///
/// ViewBuilder supports standard Swift control flow:
/// - `if` / `else` via `buildEither(first:)` and `buildEither(second:)`
/// - `if` without `else` via `buildOptional(_:)`
/// - `for` loops via `buildArray(_:)`
/// - Availability checks via `buildLimitedAvailability(_:)`
///
/// - Note: Parameter packs require macOS 14.0+ / iOS 17.0+
@resultBuilder
public struct ViewBuilder {
    
    /// Builds an empty view from an empty closure.
    ///
    /// - Returns: An `EmptyView` instance.
    public static func buildBlock() -> EmptyView { 
        EmptyView() 
    }
    
    /// Builds a view from a single child view.
    ///
    /// This overload is called when the closure contains exactly one view expression.
    ///
    /// - Parameter content: The single child view.
    /// - Returns: The child view unchanged.
    public static func buildBlock<Content: View>(_ content: Content) -> Content { 
        content 
    }
    
    /// Builds a tuple view from exactly two child views.
    ///
    /// This explicit overload prevents ambiguity with the parameter pack version.
    /// Without it, Swift's type checker would struggle to choose between the single-view
    /// and variadic versions when given two arguments.
    ///
    /// - Parameters:
    ///   - c0: The first child view.
    ///   - c1: The second child view.
    /// - Returns: A `TupleView` containing both children.
    public static func buildBlock<C0: View, C1: View>(_ c0: C0, _ c1: C1) -> TupleView<C0, C1> {
        TupleView(c0, c1)
    }
    
    /// Builds a tuple view from three or more child views using parameter packs.
    ///
    /// This is the key innovation that enables unlimited children without code generation.
    /// The first three parameters (`c0`, `c1`, `c2`) are required to ensure this overload
    /// is only chosen for 3+ arguments, avoiding ambiguity with the 2-child overload.
    ///
    /// ## How Parameter Packs Work Here
    ///
    /// ```swift
    /// VStack {
    ///     Text("A")  // c0
    ///     Text("B")  // c1
    ///     Text("C")  // c2
    ///     Text("D")  // content pack: [Text]
    ///     Text("E")  // content pack: [Text, Text]
    /// }
    /// // Type: TupleView<Text, Text, Text, Text, Text>
    /// ```
    ///
    /// - Parameters:
    ///   - c0: The first child view.
    ///   - c1: The second child view.
    ///   - c2: The third child view.
    ///   - content: A variadic parameter pack containing the remaining views (may be empty for exactly 3 children).
    /// - Returns: A `TupleView` containing all children.
    public static func buildBlock<C0: View, C1: View, C2: View, each Content: View>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ content: repeat each Content
    ) -> TupleView<C0, C1, C2, repeat each Content> {
        TupleView(c0, c1, c2, repeat each content)
    }
    
    /// Builds the "true" branch of a conditional.
    ///
    /// Called by Swift when an `if-else` statement appears in the view builder.
    ///
    /// - Parameter component: The view from the `if` branch.
    /// - Returns: A conditional content view representing the true branch.
    public static func buildEither<TrueContent: View, FalseContent: View>(
        first component: TrueContent
    ) -> _ConditionalContent<TrueContent, FalseContent> {
        _ConditionalContent.trueContent(component)
    }
    
    /// Builds the "false" branch of a conditional.
    ///
    /// Called by Swift when an `if-else` statement appears in the view builder.
    ///
    /// - Parameter component: The view from the `else` branch.
    /// - Returns: A conditional content view representing the false branch.
    public static func buildEither<TrueContent: View, FalseContent: View>(
        second component: FalseContent
    ) -> _ConditionalContent<TrueContent, FalseContent> {
        _ConditionalContent.falseContent(component)
    }
    
    /// Builds an optional view from an `if` statement without an `else`.
    ///
    /// - Parameter component: The optional view (nil if the condition was false).
    /// - Returns: The optional view unchanged.
    public static func buildOptional<Content: View>(_ component: Content?) -> Content? {
        component
    }
    
    /// Builds an array view from a `for` loop.
    ///
    /// Enables iteration within view builders:
    /// ```swift
    /// VStack {
    ///     for item in items {
    ///         Text(item)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter components: An array of views produced by the loop.
    /// - Returns: An `_ArrayView` containing all the views.
    public static func buildArray<Content: View>(_ components: [Content]) -> _ArrayView<Content> {
        _ArrayView(components)
    }
    
    /// Transforms expressions within the builder.
    ///
    /// This provides a hook for type conversions and allows more flexible inputs.
    ///
    /// - Parameter expression: A view expression.
    /// - Returns: The expression unchanged.
    public static func buildExpression<Content: View>(_ expression: Content) -> Content {
        expression
    }
    
    /// Handles views that are only available on certain platform versions.
    ///
    /// Used internally when `if #available(...)` checks are present.
    ///
    /// - Parameter component: A view with limited availability.
    /// - Returns: The view unchanged.
    public static func buildLimitedAvailability<Content: View>(_ component: Content) -> Content {
        component
    }
}

// MARK: - Helper Views

/// A view that represents a conditional branch created by `if-else` in a ViewBuilder.
///
/// This type is created automatically by `ViewBuilder.buildEither(first:)` and
/// `ViewBuilder.buildEither(second:)` when conditional logic appears in a view builder closure.
///
/// ## Example
///
/// ```swift
/// VStack {
///     if isLoggedIn {
///         Text("Welcome back!")  // TrueContent
///     } else {
///         Text("Please log in")  // FalseContent
///     }
/// }
/// ```
///
/// The encoding engine extracts whichever branch is active and processes it as a single child.
///
/// - Note: The underscore prefix indicates this is an implementation detail. Users don't
///   create `_ConditionalContent` instances directly.
public enum _ConditionalContent<TrueContent: View, FalseContent: View>: View, _ConditionalContentProtocol {
    /// The view to show when the condition is true.
    case trueContent(TrueContent)
    
    /// The view to show when the condition is false.
    case falseContent(FalseContent)
    
    /// Conditional content is a primitive, so its body is EmptyView.
    public var body: EmptyView { EmptyView() }
    
    /// Extracts the active branch as a type-erased view for encoding.
    ///
    /// Only the active branch (either true or false) is extracted and encoded.
    ///
    /// - Returns: An array containing the single active view.
    public func extractChildren() -> [any View] {
        switch self {
        case .trueContent(let view):
            return [view]
        case .falseContent(let view):
            return [view]
        }
    }
}

/// A view that represents an array of views created by a `for` loop in a ViewBuilder.
///
/// This type is created automatically by `ViewBuilder.buildArray(_:)` when a for loop
/// appears in a view builder closure.
///
/// ## Example
///
/// ```swift
/// VStack {
///     for item in items {
///         Text(item.name)
///     }
/// }
/// // Creates: _ArrayView<Text>
/// ```
///
/// During encoding, all views in the array are extracted and processed individually.
///
/// - Note: The underscore prefix indicates this is an implementation detail. Users don't
///   create `_ArrayView` instances directly.
public struct _ArrayView<Content: View>: View, _ArrayViewProtocol {
    /// The array of child views produced by the loop.
    let views: [Content]
    
    /// Creates an array view with the given views.
    ///
    /// - Parameter views: The array of child views from the loop.
    init(_ views: [Content]) {
        self.views = views
    }
    
    /// Array view is a primitive container, so its body is EmptyView.
    public var body: EmptyView { EmptyView() }
    
    /// Extracts all views from the array as type-erased views for encoding.
    ///
    /// - Returns: An array containing all child views as type-erased `View` instances.
    public func extractViews() -> [any View] {
        views.map { $0 as any View }
    }
}
