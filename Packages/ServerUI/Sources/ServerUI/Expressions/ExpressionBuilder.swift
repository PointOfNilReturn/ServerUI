import Foundation
import ViewSchema

/// Convenient builders for creating expressions on the server.
///
/// These helpers make it easy to construct expressions without verbose syntax:
///
/// ```swift
/// // Instead of:
/// Expression.binaryOp(
///     left: .binding("item::price"),
///     op: .multiply,
///     right: .binding("item::quantity")
/// )
///
/// // Write:
/// Expr.binding("item::price") * Expr.binding("item::quantity")
/// ```
///
/// ## Usage Examples
///
/// ```swift
/// // Arithmetic
/// let total = Expr.binding("price") * Expr.binding("quantity")
/// Text(expression: total)
///
/// // Comparison
/// let isAdult = Expr.binding("age") >= Expr.literal(18)
/// if isAdult { AdultContent() }
///
/// // Ternary
/// let status = Expr.binding("isPremium").ternary(
///     ifTrue: "⭐️ Premium",
///     ifFalse: "Regular"
/// )
/// Text(expression: status)
/// ```
///
/// - SeeAlso: `Expression`, `Text.init(expression:)`
public struct Expr {
    let expression: ViewSchema.Expression
    
    private init(_ expression: ViewSchema.Expression) {
        self.expression = expression
    }
    
    // MARK: - Factory Methods
    
    /// Creates a literal expression.
    ///
    /// ```swift
    /// Expr.literal("Hello")
    /// Expr.literal(42)
    /// Expr.literal(true)
    /// ```
    public static func literal(_ value: String) -> Expr {
        Expr(ViewSchema.Expression.literal(.string(value)))
    }
    
    public static func literal(_ value: Int) -> Expr {
        Expr(ViewSchema.Expression.literal(.int(value)))
    }
    
    public static func literal(_ value: Double) -> Expr {
        Expr(ViewSchema.Expression.literal(.double(value)))
    }
    
    public static func literal(_ value: Bool) -> Expr {
        Expr(ViewSchema.Expression.literal(.bool(value)))
    }
    
    /// Creates a binding expression that reads from the reactive cache.
    ///
    /// ```swift
    /// Expr.binding("user::name")
    /// Expr.binding($profile.age)  // From @Bindable
    /// ```
    public static func binding(_ stateKey: String) -> Expr {
        Expr(ViewSchema.Expression.binding(stateKey))
    }
    
    public static func binding<T>(_ binding: Binding<T>) -> Expr {
        Expr(ViewSchema.Expression.binding(binding.stateKey))
    }
    
    // MARK: - Binary Operators
    
    /// Addition: left + right
    public static func + (left: Expr, right: Expr) -> Expr {
        Expr(ViewSchema.Expression.binaryOp(left: left.expression, op: .add, right: right.expression))
    }
    
    /// Subtraction: left - right
    public static func - (left: Expr, right: Expr) -> Expr {
        Expr(ViewSchema.Expression.binaryOp(left: left.expression, op: .subtract, right: right.expression))
    }
    
    /// Multiplication: left * right
    public static func * (left: Expr, right: Expr) -> Expr {
        Expr(ViewSchema.Expression.binaryOp(left: left.expression, op: .multiply, right: right.expression))
    }
    
    /// Division: left / right
    public static func / (left: Expr, right: Expr) -> Expr {
        Expr(ViewSchema.Expression.binaryOp(left: left.expression, op: .divide, right: right.expression))
    }
    
    /// Modulo: left % right
    public static func % (left: Expr, right: Expr) -> Expr {
        Expr(ViewSchema.Expression.binaryOp(left: left.expression, op: .modulo, right: right.expression))
    }
    
    /// Equality: left == right
    public static func == (left: Expr, right: Expr) -> Expr {
        Expr(ViewSchema.Expression.binaryOp(left: left.expression, op: .equals, right: right.expression))
    }
    
    /// Inequality: left != right
    public static func != (left: Expr, right: Expr) -> Expr {
        Expr(ViewSchema.Expression.binaryOp(left: left.expression, op: .notEquals, right: right.expression))
    }
    
    /// Greater than: left > right
    public static func > (left: Expr, right: Expr) -> Expr {
        Expr(ViewSchema.Expression.binaryOp(left: left.expression, op: .greaterThan, right: right.expression))
    }
    
    /// Less than: left < right
    public static func < (left: Expr, right: Expr) -> Expr {
        Expr(ViewSchema.Expression.binaryOp(left: left.expression, op: .lessThan, right: right.expression))
    }
    
    /// Greater than or equal: left >= right
    public static func >= (left: Expr, right: Expr) -> Expr {
        Expr(ViewSchema.Expression.binaryOp(left: left.expression, op: .greaterThanOrEqual, right: right.expression))
    }
    
    /// Less than or equal: left <= right
    public static func <= (left: Expr, right: Expr) -> Expr {
        Expr(ViewSchema.Expression.binaryOp(left: left.expression, op: .lessThanOrEqual, right: right.expression))
    }
    
    /// Logical AND: left && right
    public static func && (left: Expr, right: Expr) -> Expr {
        Expr(ViewSchema.Expression.binaryOp(left: left.expression, op: .and, right: right.expression))
    }
    
    /// Logical OR: left || right
    public static func || (left: Expr, right: Expr) -> Expr {
        Expr(ViewSchema.Expression.binaryOp(left: left.expression, op: .or, right: right.expression))
    }
    
    // MARK: - Unary Operators
    
    /// Logical NOT: !expression
    public static prefix func ! (operand: Expr) -> Expr {
        Expr(ViewSchema.Expression.unaryOp(op: .not, operand: operand.expression))
    }
    
    /// Numeric negation: -expression
    public static prefix func - (operand: Expr) -> Expr {
        Expr(ViewSchema.Expression.unaryOp(op: .negate, operand: operand.expression))
    }
    
    // MARK: - Ternary
    
    /// Ternary conditional: condition ? ifTrue : ifFalse
    ///
    /// ```swift
    /// let status = Expr.binding("isPremium").ternary(
    ///     ifTrue: "⭐️ Premium",
    ///     ifFalse: "Regular"
    /// )
    /// ```
    public func ternary(ifTrue: Expr, ifFalse: Expr) -> Expr {
        Expr(ViewSchema.Expression.ternary(
            condition: self.expression,
            ifTrue: ifTrue.expression,
            ifFalse: ifFalse.expression
        ))
    }
    
    /// Ternary with string literals.
    ///
    /// ```swift
    /// Expr.binding("isPremium").ternary(ifTrue: "Premium", ifFalse: "Regular")
    /// ```
    public func ternary(ifTrue: String, ifFalse: String) -> Expr {
        self.ternary(
            ifTrue: Expr.literal(ifTrue),
            ifFalse: Expr.literal(ifFalse)
        )
    }
    
    /// Ternary with int literals.
    public func ternary(ifTrue: Int, ifFalse: Int) -> Expr {
        self.ternary(
            ifTrue: Expr.literal(ifTrue),
            ifFalse: Expr.literal(ifFalse)
        )
    }
}

// MARK: - Text Extension

public extension Text {
    /// Creates a Text view that displays the result of an expression.
    ///
    /// The expression is evaluated on the client using the reactive state cache,
    /// providing instant updates without server round-trips.
    ///
    /// ```swift
    /// // Arithmetic
    /// Text(expression: Expr.binding("price") * Expr.binding("quantity"))
    ///
    /// // Comparison
    /// Text(expression: Expr.binding("age") >= Expr.literal(18)
    ///     .ternary(ifTrue: "Adult", ifFalse: "Minor"))
    ///
    /// // Logical
    /// Text(expression: Expr.binding("isActive") && Expr.binding("isVerified")
    ///     .ternary(ifTrue: "✓ Verified", ifFalse: "Pending"))
    /// ```
    ///
    /// - Parameter expression: The expression builder to evaluate
    init(expression: Expr) {
        self.spec = .expression(expression.expression)
    }
}

// MARK: - Convenience Operators with Literals

/// Allows: Expr.binding("count") + 1
public func + (left: Expr, right: Int) -> Expr {
    left + Expr.literal(right)
}

public func + (left: Int, right: Expr) -> Expr {
    Expr.literal(left) + right
}

public func - (left: Expr, right: Int) -> Expr {
    left - Expr.literal(right)
}

public func - (left: Int, right: Expr) -> Expr {
    Expr.literal(left) - right
}

public func * (left: Expr, right: Int) -> Expr {
    left * Expr.literal(right)
}

public func * (left: Int, right: Expr) -> Expr {
    Expr.literal(left) * right
}

public func / (left: Expr, right: Int) -> Expr {
    left / Expr.literal(right)
}

public func / (left: Int, right: Expr) -> Expr {
    Expr.literal(left) / right
}

public func == (left: Expr, right: Int) -> Expr {
    left == Expr.literal(right)
}

public func == (left: Int, right: Expr) -> Expr {
    Expr.literal(left) == right
}

public func >= (left: Expr, right: Int) -> Expr {
    left >= Expr.literal(right)
}

public func >= (left: Int, right: Expr) -> Expr {
    Expr.literal(left) >= right
}

public func <= (left: Expr, right: Int) -> Expr {
    left <= Expr.literal(right)
}

public func <= (left: Int, right: Expr) -> Expr {
    Expr.literal(left) <= right
}

public func > (left: Expr, right: Int) -> Expr {
    left > Expr.literal(right)
}

public func > (left: Int, right: Expr) -> Expr {
    Expr.literal(left) > right
}

public func < (left: Expr, right: Int) -> Expr {
    left < Expr.literal(right)
}

public func < (left: Int, right: Expr) -> Expr {
    Expr.literal(left) < right
}

