import SwiftUI
import ViewSchema
import Logging

/// Evaluates expressions using values from the reactive state cache.
///
/// The `ExpressionEvaluator` provides instant UI updates by evaluating server-sent
/// expressions locally using the `ReactiveStateCache`. This eliminates the need to
/// wait for server re-renders for simple property access and string interpolation.
///
/// ## How It Works
///
/// 1. **Server sends expression**: Instead of baked values, send evaluable expressions
/// 2. **Client reads from cache**: Binding references lookup current values
/// 3. **Client evaluates**: Expressions are evaluated recursively
/// 4. **Instant updates**: When cache changes, expression re-evaluates automatically
///
/// ## Example
///
/// ```swift
/// // Server sends:
/// Expression.stringInterpolation([
///     .literal("Hello "),
///     .binding("objectID::name"),
///     .literal("!")
/// ])
///
/// // Client evaluates:
/// let evaluator = ExpressionEvaluator(cache: reactiveCache)
/// let result = evaluator.evaluate(expression)  // "Hello John!"
///
/// // User types "Jane" in TextField
/// // Cache updates → Expression re-evaluates → "Hello Jane!" (instant!)
/// ```
///
/// ## Supported Expressions (Phase 1)
///
/// - `.literal(value)` - Static values
/// - `.binding(stateKey)` - Property references from cache
/// - `.stringInterpolation([parts])` - Template strings
///
/// ## Performance
///
/// Expression evaluation is designed to be fast:
/// - Cache lookups: O(1)
/// - String concatenation: Sub-millisecond
/// - No server round-trip required
///
/// - SeeAlso: `Expression`, `ReactiveStateCache`
@MainActor
public final class ExpressionEvaluator {
    private let cache: ReactiveStateCache
    private let logger = Logger(label: "com.serverui.expressioneval")
    
    /// Creates an expression evaluator.
    ///
    /// - Parameter cache: The reactive state cache to read bindings from
    public init(cache: ReactiveStateCache) {
        self.cache = cache
    }
    
    /// Evaluates an expression to a string value.
    ///
    /// This is the main entry point for evaluation. It recursively evaluates the
    /// expression tree and returns the final string result.
    ///
    /// - Parameter expression: The expression to evaluate
    /// - Returns: The evaluated string result
    public func evaluateToString(_ expression: ViewSchema.Expression) -> String {
        // Evaluate to typed value first, then convert to string
        if let result = evaluate(expression) {
            return unwrapAndStringify(result)
        }
        return ""
    }
    
    /// Converts a value to string, properly handling optionals.
    private func unwrapAndStringify(_ value: Any) -> String {
        // Handle nil
        if value is NSNull {
            return ""
        }
        
        // Try to extract value from Optional
        let mirror = Mirror(reflecting: value)
        if mirror.displayStyle == .optional {
            // It's an Optional
            if mirror.children.isEmpty {
                // It's nil
                return ""
            } else {
                // Extract the wrapped value
                let wrappedValue = mirror.children.first!.value
                return unwrapAndStringify(wrappedValue)
            }
        }
        
        // Not optional, convert directly
        return String(describing: value)
    }
    
    /// Evaluates an expression to its typed value.
    ///
    /// This method returns the value with its proper type (String, Int, Double, Bool),
    /// which is essential for operators that require typed values.
    ///
    /// - Parameter expression: The expression to evaluate
    /// - Returns: The evaluated value with its proper type
    public func evaluate(_ expression: ViewSchema.Expression) -> Any? {
        switch expression {
        case .literal(let value):
            return value.anyValue
            
        case .binding(let stateKey):
            // Try to get value from cache - it returns Any?
            return cache.get(stateKey)
            
        case .stringInterpolation(let parts):
            // Evaluate each part and concatenate as strings
            let results = parts.map { part -> String in
                if let value = evaluate(part) {
                    return unwrapAndStringify(value)
                }
                return ""
            }
            return results.joined()
            
        case .ternary(let condition, let ifTrue, let ifFalse):
            return evaluateTernary(condition, ifTrue, ifFalse)
            
        case .binaryOp(let left, let op, let right):
            return evaluateBinaryOp(left, op, right)
            
        case .unaryOp(let op, let operand):
            return evaluateUnaryOp(op, operand)
        }
    }
    
    // MARK: - Phase 2: Operator Evaluation
    
    /// Evaluates a ternary conditional expression.
    ///
    /// - Parameters:
    ///   - condition: The condition expression (must evaluate to Bool)
    ///   - ifTrue: Expression to return if condition is true
    ///   - ifFalse: Expression to return if condition is false
    /// - Returns: The result of either ifTrue or ifFalse branch
    private func evaluateTernary(
        _ condition: ViewSchema.Expression,
        _ ifTrue: ViewSchema.Expression,
        _ ifFalse: ViewSchema.Expression
    ) -> Any? {
        guard let condResult = evaluate(condition) as? Bool else {
            logger.warning("Ternary condition did not evaluate to Bool")
            return evaluate(ifFalse)  // Default to false branch
        }
        
        return condResult ? evaluate(ifTrue) : evaluate(ifFalse)
    }
    
    /// Evaluates a binary operation between two expressions.
    ///
    /// - Parameters:
    ///   - left: Left-hand side expression
    ///   - op: The binary operator
    ///   - right: Right-hand side expression
    /// - Returns: The result of the operation
    private func evaluateBinaryOp(
        _ left: ViewSchema.Expression,
        _ op: ViewSchema.BinaryOperator,
        _ right: ViewSchema.Expression
    ) -> Any? {
        let leftValue = evaluate(left)
        let rightValue = evaluate(right)
        
        switch op {
        // Arithmetic
        case .add:
            return performArithmetic(leftValue, rightValue, +)
        case .subtract:
            return performArithmetic(leftValue, rightValue, -)
        case .multiply:
            return performArithmetic(leftValue, rightValue, *)
        case .divide:
            return performArithmetic(leftValue, rightValue, /)
        case .modulo:
            if let l = toInt(leftValue), let r = toInt(rightValue), r != 0 {
                return l % r
            }
            return nil
            
        // Comparison
        case .equals:
            return isEqual(leftValue, rightValue)
        case .notEquals:
            return !isEqual(leftValue, rightValue)
        case .greaterThan:
            return performComparison(leftValue, rightValue, >)
        case .lessThan:
            return performComparison(leftValue, rightValue, <)
        case .greaterThanOrEqual:
            return performComparison(leftValue, rightValue, >=)
        case .lessThanOrEqual:
            return performComparison(leftValue, rightValue, <=)
            
        // Logical
        case .and:
            if let l = toBool(leftValue), let r = toBool(rightValue) {
                return l && r
            }
            return false
        case .or:
            if let l = toBool(leftValue), let r = toBool(rightValue) {
                return l || r
            }
            return false
            
        // String
        case .concat:
            return unwrapAndStringify(leftValue ?? "") + unwrapAndStringify(rightValue ?? "")
        }
    }
    
    /// Evaluates a unary operation on an expression.
    ///
    /// - Parameters:
    ///   - op: The unary operator
    ///   - operand: The expression to operate on
    /// - Returns: The result of the operation
    private func evaluateUnaryOp(
        _ op: ViewSchema.UnaryOperator,
        _ operand: ViewSchema.Expression
    ) -> Any? {
        let value = evaluate(operand)
        
        switch op {
        case .not:
            if let boolValue = toBool(value) {
                return !boolValue
            }
            return true  // Default to true if not bool
            
        case .negate:
            if let intValue = value as? Int {
                return -intValue
            } else if let doubleValue = value as? Double {
                return -doubleValue
            }
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    /// Performs arithmetic operation with type coercion.
    private func performArithmetic(
        _ left: Any?,
        _ right: Any?,
        _ operation: (Double, Double) -> Double
    ) -> Any? {
        guard let l = toDouble(left), let r = toDouble(right) else {
            return nil
        }
        let result = operation(l, r)
        
        // Return Int if both operands were Int and result is whole number
        if left is Int && right is Int && result.truncatingRemainder(dividingBy: 1) == 0 {
            return Int(result)
        }
        return result
    }
    
    /// Performs comparison with type coercion.
    private func performComparison(
        _ left: Any?,
        _ right: Any?,
        _ operation: (Double, Double) -> Bool
    ) -> Bool {
        guard let l = toDouble(left), let r = toDouble(right) else {
            return false
        }
        return operation(l, r)
    }
    
    /// Checks equality with type coercion.
    private func isEqual(_ left: Any?, _ right: Any?) -> Bool {
        // Handle nil
        if left == nil && right == nil { return true }
        if left == nil || right == nil { return false }
        
        // Try numeric comparison
        if let l = toDouble(left), let r = toDouble(right) {
            return l == r
        }
        
        // Try bool comparison
        if let l = left as? Bool, let r = right as? Bool {
            return l == r
        }
        
        // String comparison
        return unwrapAndStringify(left!) == unwrapAndStringify(right!)
    }
    
    /// Converts value to Bool.
    private func toBool(_ value: Any?) -> Bool? {
        if let boolValue = value as? Bool {
            return boolValue
        }
        if let intValue = value as? Int {
            return intValue != 0
        }
        if let stringValue = value as? String {
            return stringValue.lowercased() == "true"
        }
        return nil
    }
    
    /// Converts value to Int.
    private func toInt(_ value: Any?) -> Int? {
        if let intValue = value as? Int {
            return intValue
        }
        if let doubleValue = value as? Double {
            return Int(doubleValue)
        }
        if let stringValue = value as? String {
            return Int(stringValue)
        }
        return nil
    }
    
    /// Converts value to Double.
    private func toDouble(_ value: Any?) -> Double? {
        if let doubleValue = value as? Double {
            return doubleValue
        }
        if let intValue = value as? Int {
            return Double(intValue)
        }
        if let stringValue = value as? String {
            return Double(stringValue)
        }
        return nil
    }
}

