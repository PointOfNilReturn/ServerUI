import SwiftUI
import ViewSchema

/// Wrapper view for state-bound text that can use optimistic updates.
/// A text view that reads from the reactive state cache for instant updates.
///
/// `OptimisticText` displays text that's bound to a state key. It reads from the
/// `ReactiveStateCache` which provides instant updates as the user types, before
/// the server even confirms the change.
struct OptimisticText: View {
    let stateKey: String
    let fallbackValue: String
    @Environment(\.reactiveStateCache) private var cache
    
    var body: some View {
        let displayValue: String = cache?.get(stateKey) ?? fallbackValue
        Text(verbatim: displayValue)
    }
}

/// A text view that evaluates expressions using the reactive state cache.
///
/// `ExpressionText` evaluates server-sent expressions locally, providing instant
/// updates (0ms latency) for property access, string interpolation, and simple logic.
///
/// ## How It Works
///
/// 1. Server sends an `Expression` (e.g., string interpolation with bindings)
/// 2. Client creates `ExpressionEvaluator` with `ReactiveStateCache`
/// 3. Expression is evaluated to a string
/// 4. When cache changes, SwiftUI automatically re-evaluates
/// 5. Text updates instantly!
///
/// ## Example
///
/// ```swift
/// // Server sends: Expression.stringInterpolation([
/// //   .literal("Hello "),
/// //   .binding("objectID::name"),
/// //   .literal("!")
/// // ])
/// //
/// // Client renders: "Hello John!"
/// // User types "Jane" → instantly shows: "Hello Jane!"
/// ```
struct ExpressionText: View {
    let expression: ViewSchema.Expression
    @Environment(\.reactiveStateCache) private var cache
    
    var body: some View {
        if let cache = cache {
            let evaluator = ExpressionEvaluator(cache: cache)
            let result = evaluator.evaluateToString(expression)
            Text(verbatim: result)
        } else {
            // Fallback if cache not available (shouldn't happen)
            Text(verbatim: "")
        }
    }
}

/// Extension to create SwiftUI Text views from TextSpec.
///
/// This extension handles the conversion from ServerUI's `TextSpec` to SwiftUI's `Text`,
/// preserving the original initializer's intent (localized, verbatim, markdown, dates, etc.).
///
/// This is a key part of the **initializer fidelity** pattern, where the server explicitly
/// specifies which Text initializer was used, allowing the client to call the exact same
/// initializer on SwiftUI's Text type.
public extension Text {
    /// Creates a SwiftUI Text view from a TextSpec.
    ///
    /// The initializer used depends on the TextSpec case:
    /// - `.localized(_)` → Uses `Text(_ content: LocalizedStringKey)` for localization
    /// - `.verbatim(_)` → Uses `Text(verbatim:)` for literal rendering
    /// - `.markdown(_)` → Uses `Text(_ markdown: LocalizedStringKey)` (iOS 15+)
    /// - `.dateStyled(_:_)` → Uses `Text(_ date: Date, style:)` for formatted dates
    /// - `.dateRange(_:_)` → Uses `Text(_ dateRange:)` for date ranges
    /// - `.timerInterval(_:_:_)` → Uses `Text(timerInterval:pauseTime:)` (iOS 14+)
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Server sends: TextSpec.localized("greeting.hello")
    /// let text1 = Text(spec) // Client creates: Text("greeting.hello")
    ///
    /// // Server sends: TextSpec.verbatim("©2024")
    /// let text2 = Text(spec) // Client creates: Text(verbatim: "©2024")
    ///
    /// // Server sends: TextSpec.markdown("**Bold**")
    /// let text3 = Text(spec) // Client creates: Text("**Bold**") with markdown parsing
    /// ```
    ///
    /// - Parameter spec: The text specification from the server.
    init(_ spec: TextSpec) {
        switch spec {
        case .localized(let string):
            // Create localizable text - SwiftUI will look it up in .strings files
            self.init(LocalizedStringKey(string))
            
        case .verbatim(let string):
            // Create literal text - no localization lookup
            self.init(verbatim: string)
            
        case .markdown(let string):
            // Create markdown-formatted text
            if #available(iOS 15, macOS 12, *) {
                // Parse markdown on the client
                self.init(LocalizedStringKey(string))
            } else {
                // Fallback: display as plain text on older OS versions
                self.init(verbatim: string)
            }
            
        case .dateStyled(let date, let style):
            // Create formatted date text (conversion in Conversions.swift)
            self.init(date, style: style.toSwiftUI)
            
        case .dateRange(let start, let end):
            // Create date range text
            self.init(start...end)
            
        case .timerInterval(let start, let end, let pauseTime):
            // Create timer text
            if #available(iOS 14, macOS 11, *) {
                self.init(timerInterval: start...end, pauseTime: pauseTime)
            } else {
                // Fallback: show start date on older OS versions
                self.init(start, style: .date)
            }
        case .stateBound(stateKey: _, fallbackValue: let fallbackValue):
            // State-bound text is handled by OptimisticText in Renderer.swift
            // This case is here for completeness but shouldn't normally be reached
            // since the Renderer checks for .stateBound before calling this init
            self.init(verbatim: fallbackValue)
            
        case .expression(_):
            // Expression text is handled by ExpressionText in Renderer.swift
            // This case is here for completeness but shouldn't normally be reached
            // since the Renderer checks for .expression before calling this init
            self.init(verbatim: "")
        }
    }
}

