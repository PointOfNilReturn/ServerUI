import Foundation

/// A client-evaluable expression that can reference state bindings and literals.
///
/// Expressions enable instant UI updates without server re-renders by allowing the client
/// to evaluate property access, string interpolation, and simple operations using values
/// from the `ReactiveStateCache`.
///
/// ## Overview
///
/// When the server encodes a view that references observable properties, it can capture
/// those references as expressions instead of baked values:
///
/// ```swift
/// // Server-side
/// Text("Hello \(profile.name)!")
///
/// // Encoded as expression
/// Expression.stringInterpolation([
///     .literal("Hello "),
///     .binding("objectID::name"),
///     .literal("!")
/// ])
/// ```
///
/// The client evaluates the expression by reading from the cache, providing instant updates
/// as the user types without waiting for server confirmation.
///
/// ## Phase 1: Foundation
///
/// Currently supports:
/// - `.literal` - Static values
/// - `.binding` - Observable property references
/// - `.stringInterpolation` - Template strings with bindings
///
/// ## See Also
///
/// - `ExpressionEvaluator` (ClientUI) - Evaluates expressions using the reactive cache
/// - `ReactiveStateCache` (ClientUI) - Provides binding values
/// - [Expression System Roadmap](x-source-tag://EXPRESSION_SYSTEM)
public indirect enum Expression: Codable, Equatable, Sendable, Hashable {
    /// A static literal value.
    ///
    /// Literals are evaluated to their contained value without any cache lookups.
    ///
    /// - Parameter value: The static value (String, Int, Double, Bool)
    case literal(ExpressionValue)
    
    /// A reference to a state binding in the reactive cache.
    ///
    /// When evaluated, the binding key is used to lookup the current value in
    /// the `ReactiveStateCache`.
    ///
    /// - Parameter stateKey: The cache key (e.g., "objectID::propertyName")
    case binding(String)
    
    /// A string template with interpolated expressions.
    ///
    /// String interpolation combines static text with dynamic bindings:
    ///
    /// ```swift
    /// Expression.stringInterpolation([
    ///     .literal("User: "),
    ///     .binding("objectID::name"),
    ///     .literal(", Age: "),
    ///     .binding("objectID::age")
    /// ])
    /// ```
    ///
    /// The client evaluates each part and concatenates the results.
    ///
    /// - Parameter parts: Array of expressions to concatenate
    case stringInterpolation([Expression])
    
    // MARK: - Phase 2: Operators
    
    /// A ternary conditional expression: `condition ? ifTrue : ifFalse`
    ///
    /// Evaluates the condition, then returns either `ifTrue` or `ifFalse` based on the result.
    ///
    /// ```swift
    /// Expression.ternary(
    ///     condition: .binding("user::isPremium"),
    ///     ifTrue: .literal(.string("⭐️ Premium")),
    ///     ifFalse: .literal(.string("Regular"))
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - condition: Expression that evaluates to a boolean
    ///   - ifTrue: Expression to return if condition is true
    ///   - ifFalse: Expression to return if condition is false
    case ternary(condition: Expression, ifTrue: Expression, ifFalse: Expression)
    
    /// A binary operation between two expressions.
    ///
    /// Supports arithmetic, comparison, and logical operators:
    ///
    /// ```swift
    /// // Arithmetic: price * quantity
    /// Expression.binaryOp(
    ///     left: .binding("item::price"),
    ///     op: .multiply,
    ///     right: .binding("item::quantity")
    /// )
    ///
    /// // Comparison: age >= 18
    /// Expression.binaryOp(
    ///     left: .binding("user::age"),
    ///     op: .greaterThanOrEqual,
    ///     right: .literal(.int(18))
    /// )
    ///
    /// // Logical: isActive && isVerified
    /// Expression.binaryOp(
    ///     left: .binding("user::isActive"),
    ///     op: .and,
    ///     right: .binding("user::isVerified")
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - left: Left-hand side expression
    ///   - op: The binary operator to apply
    ///   - right: Right-hand side expression
    case binaryOp(left: Expression, op: BinaryOperator, right: Expression)
    
    /// A unary operation on a single expression.
    ///
    /// Supports negation and logical NOT:
    ///
    /// ```swift
    /// // Logical NOT: !isActive
    /// Expression.unaryOp(op: .not, operand: .binding("user::isActive"))
    ///
    /// // Negation: -value
    /// Expression.unaryOp(op: .negate, operand: .binding("item::discount"))
    /// ```
    ///
    /// - Parameters:
    ///   - op: The unary operator to apply
    ///   - operand: The expression to operate on
    case unaryOp(op: UnaryOperator, operand: Expression)
    
    // MARK: - Phase 3: Advanced (Future)
    
    // case optionalChaining(Expression, [String])
    // case nilCoalescing(Expression, Expression)
    // case propertyPath(base: Expression, path: [String])
}

/// Binary operators for use in expressions.
///
/// These operators work on two operands and follow standard precedence rules.
public enum BinaryOperator: String, Codable, Equatable, Sendable, Hashable {
    // MARK: - Arithmetic
    case add = "+"
    case subtract = "-"
    case multiply = "*"
    case divide = "/"
    case modulo = "%"
    
    // MARK: - Comparison
    case equals = "=="
    case notEquals = "!="
    case greaterThan = ">"
    case lessThan = "<"
    case greaterThanOrEqual = ">="
    case lessThanOrEqual = "<="
    
    // MARK: - Logical
    case and = "&&"
    case or = "||"
    
    // MARK: - String
    case concat = "++"  // String concatenation
}

/// Unary operators for use in expressions.
///
/// These operators work on a single operand.
public enum UnaryOperator: String, Codable, Equatable, Sendable, Hashable {
    /// Logical NOT: `!condition`
    case not = "!"
    
    /// Numeric negation: `-value`
    case negate = "-"
}

/// A type-erased value that can be used in expressions.
///
/// Supports the common types used in UI state: String, Int, Double, Bool.
/// This is similar to `StateValue` but used specifically for expression literals.
public enum ExpressionValue: Codable, Equatable, Sendable, Hashable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported expression value type"
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
    
    /// Extracts the value as an Any for use in evaluation.
    public var anyValue: Any? {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return value
        case .double(let value):
            return value
        case .bool(let value):
            return value
        case .null:
            return nil
        }
    }
    
    /// Converts the value to a String for display.
    public var stringValue: String {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return String(value)
        case .double(let value):
            return String(value)
        case .bool(let value):
            return String(value)
        case .null:
            return ""
        }
    }
}

