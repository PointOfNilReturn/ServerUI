import Foundation
import ServerUI

/// Demo showcasing Phase 2 operators: arithmetic, comparison, logical, and ternary expressions.
///
/// This demo shows how expressions are evaluated on the client for instant updates without
/// server round-trips.

// Sample data classes
@RemotelyObservable
class ShoppingCart: @unchecked Sendable {
    var itemPrice: Int = 25
    var quantity: Int = 2
    var taxRate: Double = 0.08
    var hasCoupon: Bool = false
    var discount: Int = 5
}

@RemotelyObservable
class UserAccount: @unchecked Sendable {
    var age: Int = 25
    var score: Int = 85
    var isActive: Bool = true
    var isVerified: Bool = true
}

private struct OperatorDemoScreen: View {
    @State private var cart = ShoppingCart()
    @State private var user = UserAccount()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Operator Expressions Demo")
                    .font(.largeTitle)
                
                Text("Phase 2: All operators evaluate instantly on the client! ⚡️")
                    .font(.caption)
                
                // Arithmetic Section
                ArithmeticDemo(cart: cart)
                
                Text("---").padding()
                
                // Comparison Section
                ComparisonDemo(user: user)
                
                Text("---").padding()
                
                // Logical Section
                LogicalDemo(user: user)
                
                Text("---").padding()
                
                // Ternary Section
                TernaryDemo(cart: cart, user: user)
                
                Text("---").padding()
                
                // Controls
                ControlSection(cart: cart, user: user)
            }
            .padding()
        }
        .navigationTitle("Operators Demo")
    }
}

/// Demonstrates arithmetic operators: +, -, *, /, %
private struct ArithmeticDemo: View {
    @Bindable var cart: ShoppingCart
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Arithmetic Operators")
                .font(.headline)
            
            // Input controls
            HStack {
                Text("Price: $\($cart.itemPrice)")
                Button("+$5") { cart.itemPrice += 5 }
                Button("-$5") { cart.itemPrice -= 5 }
                
                Text("Qty: \($cart.quantity)")
                Button("+1") { cart.quantity += 1 }
                Button("-1") { if cart.quantity > 0 { cart.quantity -= 1 } }
            }
            
            // Subtotal: price * quantity
            Text(expression: Expr.literal("Subtotal: $") +
                (Expr.binding($cart.itemPrice) * Expr.binding($cart.quantity)))
                .font(.body)
            
            // With discount: subtotal - discount
            Text(expression: Expr.literal("After $5 off: $") +
                ((Expr.binding($cart.itemPrice) * Expr.binding($cart.quantity)) - Expr.literal(5)))
                .font(.body)
            
            // With tax: subtotal * (1 + taxRate)
            // Note: For now showing subtotal only (taxRate is Double)
            Text("✨ All calculations update instantly as you type!")
                .font(.caption)
        }
        .padding()
    }
}

/// Demonstrates comparison operators: ==, !=, >, <, >=, <=
private struct ComparisonDemo: View {
    @Bindable var user: UserAccount
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Comparison Operators")
                .font(.headline)
            
            // Input controls
            HStack {
                Text("Age: \($user.age)")
                Button("+10") { user.age += 10 }
                Button("-10") { if user.age > 10 { user.age -= 10 } }
                
                Text("Score: \($user.score)")
                Button("+10") { user.score += 10 }
                Button("-10") { if user.score > 10 { user.score -= 10 } }
            }
            
            // age >= 18
            Text(expression: (Expr.binding($user.age) >= 18)
                .ternary(ifTrue: "✓ Adult (age >= 18)", ifFalse: "✗ Minor (age < 18)"))
                .font(.body)
            
            // age >= 21
            Text(expression: (Expr.binding($user.age) >= 21)
                .ternary(ifTrue: "✓ Can drink (age >= 21)", ifFalse: "✗ Too young (age < 21)"))
                .font(.body)
            
            // score >= 90
            Text(expression: (Expr.binding($user.score) >= 90)
                .ternary(ifTrue: "🏆 Grade: A", ifFalse: "📝 Grade: B or lower"))
                .font(.body)
            
            // score == 100
            Text(expression: (Expr.binding($user.score) == 100)
                .ternary(ifTrue: "⭐️ Perfect score!", ifFalse: "Keep trying!"))
                .font(.body)
            
            Text("✨ Comparisons evaluate instantly!")
                .font(.caption)
        }
        .padding()
    }
}

/// Demonstrates logical operators: &&, ||, !
private struct LogicalDemo: View {
    @Bindable var user: UserAccount
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Logical Operators")
                .font(.headline)
            
            // Toggle controls
            HStack {
                Button(user.isActive ? "Active ✓" : "Active ✗") {
                    user.isActive.toggle()
                }
                Button(user.isVerified ? "Verified ✓" : "Verified ✗") {
                    user.isVerified.toggle()
                }
            }
            
            // isActive && isVerified
            Text(expression: (Expr.binding($user.isActive) && Expr.binding($user.isVerified))
                .ternary(ifTrue: "✅ Full access (active AND verified)", ifFalse: "⚠️ Limited access"))
                .font(.body)
            
            // isActive || isVerified
            Text(expression: (Expr.binding($user.isActive) || Expr.binding($user.isVerified))
                .ternary(ifTrue: "✓ Some access (active OR verified)", ifFalse: "✗ No access"))
                .font(.body)
            
            // !isActive
            Text(expression: (!Expr.binding($user.isActive))
                .ternary(ifTrue: "❌ Account suspended", ifFalse: "✓ Account active"))
                .font(.body)
            
            Text("✨ Logical operations evaluate instantly!")
                .font(.caption)
        }
        .padding()
    }
}

/// Demonstrates ternary conditional operator: condition ? ifTrue : ifFalse
private struct TernaryDemo: View {
    @Bindable var cart: ShoppingCart
    @Bindable var user: UserAccount
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ternary Conditionals")
                .font(.headline)
            
            // Coupon toggle
            Button(cart.hasCoupon ? "Coupon Applied ✓" : "Apply Coupon") {
                cart.hasCoupon.toggle()
            }
            
            // hasCoupon ? "Discounted!" : "Full price"
            Text(expression: Expr.binding($cart.hasCoupon)
                .ternary(ifTrue: "💰 10% discount applied!", ifFalse: "Regular price"))
                .font(.body)
            
            // Complex: (age >= 65 || age <= 12) ? "Senior/Child discount" : "Regular"
            Text(expression: ((Expr.binding($user.age) >= 65) || (Expr.binding($user.age) <= 12))
                .ternary(ifTrue: "👴👶 Special pricing", ifFalse: "Regular adult pricing"))
                .font(.body)
            
            // Nested ternary (not recommended but supported):
            // score >= 90 ? "A" : score >= 80 ? "B" : "C"
            Text(expression: (Expr.binding($user.score) >= 90)
                .ternary(
                    ifTrue: Expr.literal("Grade: A (90+)"),
                    ifFalse: Expr.literal("Grade: B or C")
                ))
                .font(.body)
            
            Text("✨ Ternaries let you show different text based on conditions!")
                .font(.caption)
        }
        .padding()
    }
}

/// Control section for adjusting values
private struct ControlSection: View {
    @Bindable var cart: ShoppingCart
    @Bindable var user: UserAccount
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Quick Controls")
                .font(.headline)
            
            HStack {
                Button("Reset Cart") {
                    cart.itemPrice = 25
                    cart.quantity = 2
                    cart.hasCoupon = false
                }
                
                Button("Reset User") {
                    user.age = 25
                    user.score = 85
                    user.isActive = true
                    user.isVerified = true
                }
            }
            
            HStack {
                Button("Set High Score") {
                    user.score = 95
                }
                
                Button("Set Low Score") {
                    user.score = 70
                }
            }
            
            Text("💡 Try changing values and watch expressions update instantly!")
                .font(.caption)
        }
        .padding()
    }
}

enum OperatorDemoHandler {
    static func response() -> Data {
        let view = OperatorDemoScreen()
        guard let json = try? ServerUIJSON.encode(view) else {
            let errorBody = Data(#"{ "error": "encoding failed" }"#.utf8)
            return HTTP.buildResponse(status: "500 Internal Server Error", body: errorBody)
        }
        return HTTP.buildResponse(body: json)
    }
}

