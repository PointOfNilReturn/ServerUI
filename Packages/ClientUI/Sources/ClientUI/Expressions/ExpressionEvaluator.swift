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
        switch expression {
        case .literal(let value):
            return value.stringValue
            
        case .binding(let stateKey):
            // Read from cache
            if let cachedValue: String = cache.get(stateKey) {
                logger.trace("Evaluated binding", metadata: [
                    "key": "\(stateKey)",
                    "value": "\(cachedValue)"
                ])
                return cachedValue
            } else {
                logger.warning("Binding not found in cache", metadata: ["key": "\(stateKey)"])
                return ""
            }
            
        case .stringInterpolation(let parts):
            // Evaluate each part and concatenate
            let results = parts.map { evaluateToString($0) }
            return results.joined()
        }
    }
    
    // MARK: - Future Phases
    
    // Phase 2: Operator Evaluation
    /*
    /// Evaluates an expression to its raw typed value.
    ///
    /// This method returns the value without string conversion, useful for
    /// Phase 2 operators that need typed values (e.g., Boolean for conditionals,
    /// Int for arithmetic).
    ///
    /// - Parameter expression: The expression to evaluate
    /// - Returns: The evaluated value as Any?
    public func evaluate(_ expression: Expression) -> Any? {
        switch expression {
        case .literal(let value):
            return value.anyValue
            
        case .binding(let stateKey):
            // Use cache's generic get method
            let value: Any? = cache.get(stateKey)
            return value
            
        case .stringInterpolation(let parts):
            return evaluateToString(expression)
            
        // Phase 2:
        case .binaryOp(let left, let op, let right):
            return evaluateBinaryOp(left, op, right)
        case .ternary(let condition, let ifTrue, let ifFalse):
            return evaluateTernary(condition, ifTrue, ifFalse)
        }
    }
    
    private func evaluateBinaryOp(_ left: Expression, _ op: BinaryOperator, _ right: Expression) -> Any? {
        let leftValue = evaluate(left)
        let rightValue = evaluate(right)
        
        switch op {
        case .equals:
            return isEqual(leftValue, rightValue)
        case .add:
            return add(leftValue, rightValue)
        // ... other operators
        }
    }
    
    private func evaluateTernary(_ condition: Expression, _ ifTrue: Expression, _ ifFalse: Expression) -> Any? {
        if let condResult = evaluate(condition) as? Bool {
            return condResult ? evaluate(ifTrue) : evaluate(ifFalse)
        }
        return nil
    }
    */
}

