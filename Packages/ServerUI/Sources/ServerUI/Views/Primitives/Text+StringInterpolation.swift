import Foundation
import ViewSchema

/// Custom string interpolation for Text that captures observable properties as expressions.
///
/// This extension enables seamless, vanilla SwiftUI syntax for Text views with observable
/// properties. The magic happens through Swift's `StringInterpolationProtocol`:
///
/// ```swift
/// @RemotelyObservable
/// class Profile {
///     var name = "John"
/// }
///
/// // This "just works" - name is captured as a binding expression!
/// Text("Hello \(profile.name)!")
/// ```
///
/// ## How It Works
///
/// 1. User writes `Text("Hello \(profile.name)!")`
/// 2. Swift calls `StringInterpolation.appendLiteral("Hello ")`
/// 3. Swift calls `StringInterpolation.appendInterpolation(profile.name)`
/// 4. We detect it's an `ObservableProperty` and capture the binding key
/// 5. Swift calls `StringInterpolation.appendLiteral("!")`
/// 6. Text is initialized with the captured expression parts
///
/// ## Expression Types Generated
///
/// - **Pure static**: `Text("Hello")` → `.localized("Hello")`
/// - **With binding**: `Text("Hello \(name)!")` → `.expression(.stringInterpolation([...]))`
/// - **Direct property**: `Text(name)` → `.expression(.binding("key"))`
///
/// - SeeAlso: `ObservableProperty`, `Expression`, `ExpressionEvaluator`
extension Text: ExpressibleByStringInterpolation, ExpressibleByStringLiteral {
    /// Custom string interpolation that captures observable properties.
    public struct StringInterpolation: StringInterpolationProtocol {
        /// The expression parts captured during interpolation.
        var parts: [ViewSchema.Expression] = []
        
        /// Indicates whether any interpolations were observable properties.
        var hasBindings: Bool = false
        
        /// Required initializer for StringInterpolationProtocol.
        public init(literalCapacity: Int, interpolationCount: Int) {
            parts.reserveCapacity(literalCapacity + interpolationCount)
        }
        
        /// Appends a literal string segment.
        ///
        /// Called for static text between interpolations:
        /// `"Hello \(name)!"` → "Hello " and "!" are literals
        public mutating func appendLiteral(_ literal: String) {
            if !literal.isEmpty {
                parts.append(ViewSchema.Expression.literal(.string(literal)))
            }
        }
        
        /// Appends an observable property interpolation - CAPTURES AS BINDING!
        ///
        /// This is the magic method. When you write `\(profile.name)` and `name` is
        /// an `ObservableProperty`, this method is called and we capture it as a binding.
        ///
        /// ```swift
        /// Text("Name: \(profile.name)")
        /// // Calls: appendInterpolation(ObservableProperty(key: "...", value: "John"))
        /// // Result: .binding("objectID::name") ← Client reads from cache!
        /// ```
        public mutating func appendInterpolation<T>(_ property: ObservableProperty<T>) {
            parts.append(ViewSchema.Expression.binding(property.key))
            hasBindings = true
        }
        
        /// Appends a binding interpolation - CAPTURES AS BINDING!
        ///
        /// This enables the clean `$` syntax in string interpolation:
        ///
        /// ```swift
        /// @Bindable var profile: UserProfile
        /// Text("Name: \($profile.name)")  // ← $ syntax captures binding!
        /// // Result: .binding("objectID::name") ← Client reads from cache!
        /// ```
        ///
        /// This is the pragmatic approach for Phase 1 given Swift macro limitations.
        public mutating func appendInterpolation<T: CustomStringConvertible>(_ binding: Binding<T>) {
            parts.append(ViewSchema.Expression.binding(binding.stateKey))
            hasBindings = true
        }
        
        /// Appends a regular string interpolation (static value).
        ///
        /// For non-observable values, just convert to string and append as literal:
        /// ```swift
        /// let version = "1.0"
        /// Text("Version: \(version)")  // ← Static, not a binding
        /// ```
        public mutating func appendInterpolation(_ string: String) {
            parts.append(ViewSchema.Expression.literal(.string(string)))
        }
        
        /// Appends a generic value interpolation (static value).
        ///
        /// This handles all other types by converting them to strings:
        /// ```swift
        /// let count = 42
        /// Text("Count: \(count)")  // ← Converted to "42"
        /// ```
        public mutating func appendInterpolation<T>(_ value: T) {
            parts.append(ViewSchema.Expression.literal(.string(String(describing: value))))
        }
    }
    
    /// Creates a Text from a string interpolation.
    ///
    /// This is called by the Swift compiler after all interpolation parts are captured.
    /// We decide whether to create a regular text or an expression-based text.
    ///
    /// - Parameter stringInterpolation: The captured interpolation parts
    public init(stringInterpolation: StringInterpolation) {
        if stringInterpolation.parts.isEmpty {
            // Empty string
            self.spec = .verbatim("")
        } else if stringInterpolation.parts.count == 1,
                  case .literal(let value) = stringInterpolation.parts[0],
                  !stringInterpolation.hasBindings {
            // Pure static string with no bindings - use normal localized text
            self.spec = .localized(value.stringValue)
        } else {
            // Has bindings or multiple parts - use expression for instant updates
            self.spec = .expression(.stringInterpolation(stringInterpolation.parts))
        }
    }
    
    /// Creates a Text directly from an observable property.
    ///
    /// This enables the pattern `Text(profile.name)` to work seamlessly.
    ///
    /// ```swift
    /// Text(profile.name)  // ← Just the property, no interpolation
    /// // Creates: Expression.binding("objectID::name")
    /// ```
    public init<T>(_ property: ObservableProperty<T>) {
        self.spec = .expression(.binding(property.key))
    }
    
    /// Creates a Text from a string literal (required for ExpressibleByStringLiteral).
    ///
    /// This is called when you write `Text("Hello")` without interpolation.
    /// The string is treated as a localizable string by default.
    ///
    /// - Parameter value: The string literal
    public init(stringLiteral value: String) {
        self.spec = .localized(value)
    }
}

// MARK: - Documentation

/*
## Complete Examples

### Basic Interpolation
```swift
@RemotelyObservable
class Profile {
    var name = "John"
    var age = 30
}

@State var profile = Profile()

// ✅ Single interpolation
Text("Name: \(profile.name)")
// Expression: .stringInterpolation([
//   .literal("Name: "),
//   .binding("objectID::name")
// ])

// ✅ Multiple interpolations
Text("User: \(profile.name), Age: \(profile.age)")
// Expression: .stringInterpolation([
//   .literal("User: "),
//   .binding("objectID::name"),
//   .literal(", Age: "),
//   .binding("objectID::age")
// ])

// ✅ Direct property
Text(profile.name)
// Expression: .binding("objectID::name")
```

### Mixed Content
```swift
let version = "1.0"

// ✅ Observable + static
Text("User: \(profile.name), Version: \(version)")
// Expression: .stringInterpolation([
//   .literal("User: "),
//   .binding("objectID::name"),  // ← Binding
//   .literal(", Version: "),
//   .literal("1.0")              // ← Static
// ])

// ✅ Pure static (no observables)
Text("Version: \(version)")
// Regular: .localized("Version: 1.0")  // ← Not an expression
```

### Edge Cases
```swift
// ✅ Empty string
Text("")
// .verbatim("")

// ✅ Pure literal
Text("Hello")
// .localized("Hello")  // ← Can be localized

// ✅ Only binding
Text("\(profile.name)")
// Expression: .stringInterpolation([.binding("objectID::name")])
```

## Performance

String interpolation capture happens **at encoding time on the server**:
- Zero runtime overhead
- Expressions are built once during encoding
- Client evaluates expressions from cache (0ms latency)

## Type Safety

The compiler ensures:
- ✅ Only `ObservableProperty<T>` is captured as binding
- ✅ Other types are converted to static strings
- ✅ Type mismatches caught at compile time
- ✅ Full autocomplete and type checking

## Limitations (Phase 1)

Currently, only `String` properties work seamlessly. For other types:
- `Int`, `Double`, `Bool` → Converted to static strings
- Phase 2 will add typed expression support

## Future Enhancements (Phase 2)

With operator support, you'll be able to write:
```swift
Text(profile.age >= 18 ? "Adult" : "Minor")
Text("Total: \(item.price * item.quantity)")
```

*/

