# Expression System Roadmap

A client-side expression evaluation system that enables instant UI updates for property access, string interpolation, and simple logic without requiring server re-renders.

## Overview

The expression system allows the server to send **evaluable expressions** instead of baked values. The client evaluates these expressions using the `ReactiveStateCache`, providing instant updates (0ms latency) for common patterns.

## Architecture

```
Server (Encoding)          Client (Evaluation)
     │                            │
     ├─ Detect property access    │
     ├─ Capture as Expression     │
     ├─ Serialize to JSON ────────┼─→ ExpressionEvaluator
     │                            │   ├─ Read from cache
     │                            │   ├─ Evaluate expression
     │                            │   └─ Update UI instantly
```

## Implementation Phases

### Phase 1: Foundation ✅ **COMPLETE**

**Goal:** Support property bindings and string interpolation

**Components:**
- `Expression` enum in ViewSchema
  - `.literal(value)` - Static values
  - `.binding(stateKey)` - Observable property reference
  - `.stringInterpolation([Expression])` - Template strings
  
- `ExpressionEvaluator` in ClientUI
  - Reads from `ReactiveStateCache`
  - Evaluates expressions recursively
  - Returns evaluated values

- Updated Text rendering
  - `TextSpec.expression(Expression)` variant
  - Client evaluates and displays result
  - Re-evaluates when cache changes

**Examples Enabled:**
```swift
// Property access
Text(profile.name)  // ← Instant update

// String interpolation  
Text("Hello \(profile.name)!")  // ← Instant update

// Multiple interpolations
Text("User: \(profile.name), Age: \(profile.age)")  // ← Instant update
```

**Challenges:**
- Detecting property access at encoding time (macro enhancement)
- String interpolation capture
- Integration with existing `Text(binding:)` pattern

---

### Phase 2: Operators ✅ **COMPLETE**

**Goal:** Support simple conditional logic and comparisons

**New Expression Types:**
- `.binaryOp(left, operator, right)` - Binary operations
- `.unaryOp(operator, operand)` - Unary operations  
- `.ternary(condition, ifTrue, ifFalse)` - Conditional expressions

**Binary Operators:**
```swift
enum BinaryOperator {
    // Arithmetic
    case add, subtract, multiply, divide, modulo
    
    // Comparison
    case equals, notEquals
    case greaterThan, lessThan
    case greaterThanOrEqual, lessThanOrEqual
    
    // Logical
    case and, or
    
    // String
    case concat
}
```

**Unary Operators:**
```swift
enum UnaryOperator {
    case not        // !condition
    case negate     // -value
}
```

**Examples Enabled:**
```swift
// Ternary operators
Text(profile.isPremium ? "⭐️ Premium" : "Regular")

// Comparisons
if profile.age >= 18 {
    AdultContent()
}

// Logical operators
if profile.isActive && profile.isVerified {
    VerifiedBadge()
}

// Arithmetic
Text("Total: \(item.price * item.quantity)")
```

**Challenges:**
- Operator precedence
- Type coercion (String to Int, etc.)
- Short-circuit evaluation for `&&` and `||`

---

### Phase 3: Advanced Features 🚀 (Future)

**Goal:** Handle Swift-specific patterns and edge cases

**New Expression Types:**
- `.optionalChaining(Expression, [String])` - Optional property access
- `.nilCoalescing(Expression, Expression)` - `??` operator
- `.cast(Expression, Type)` - Type casting
- `.arrayAccess(Expression, Expression)` - `array[index]`
- `.propertyPath(base: Expression, path: [String])` - Nested properties

**Examples Enabled:**
```swift
// Optional chaining
Text(profile.address?.city ?? "Unknown")

// Nested properties
Text(profile.company.name)

// Array access
Text(items[0].name)

// Computed with optionals
Text(profile.fullName ?? "Anonymous")
```

**Challenges:**
- Optional handling complexity
- Type system integration
- Performance for deeply nested expressions

---

### Phase 4: Control Flow (Experimental) 🧪

**Goal:** Client-side conditional rendering for simple cases

**New Expression Types:**
- `.conditional(condition, ifTrue, ifFalse)` - For view rendering
- `.switch(value, cases)` - Switch statements

**Example:**
```swift
// Client evaluates which view to show
if profile.role == .admin {
    AdminPanel()
} else if profile.role == .moderator {
    ModeratorPanel()
} else {
    UserPanel()
}
```

**Why Experimental:**
- Blurs server/client responsibility
- Security implications (client controls logic)
- May violate "server as source of truth"

**Use Case:** Simple UI toggles that don't need server logic

---

## Design Decisions

### What Should Be Expressions?

✅ **Good candidates:**
- Property access: `profile.name`
- String interpolation: `"Hello \(name)"`
- Simple operators: `age >= 18`
- Ternary: `isPremium ? "⭐️" : ""`
- Comparisons: `count == 0`

❌ **Should stay server-side:**
- Function calls: `validateUser(profile)`
- API calls: `await fetchData()`
- Complex business logic
- Custom types/protocols
- Side effects

### Security Considerations

- Client can only evaluate expressions **sent by server**
- No arbitrary code execution
- Expressions are deterministic
- Server controls available data (via cache keys)

### Performance

- Expression evaluation is **synchronous** and fast (~microseconds)
- Cache reads are O(1) lookups
- String concatenation is the slowest operation (still sub-millisecond)

---

## Migration Path

### Current State
```swift
// Explicit binding required
Text(binding: $profile.name)
```

### Phase 1
```swift
// String interpolation works
Text("Name: \(profile.name)")  // ← Automatic expression
```

### Phase 2
```swift
// Conditionals work  
Text(profile.isPremium ? "⭐️ Premium" : "Regular")
```

### Phase 3+
```swift
// Optional chaining works
Text(profile.address?.city ?? "Unknown")
```

### Backwards Compatibility

The `Text(binding:)` pattern will continue to work and may even be simplified to use the expression system internally.

---

## Technical Challenges

### 1. Property Access Detection

**Challenge:** How does ServerUI know when `profile.name` is accessed?

**Options:**
- Macro-generated wrapper types
- String interpolation hooks
- Runtime inspection (Mirror)
- Custom DSL

**Current approach:** Use existing `Text(binding:)` as proof-of-concept, extend later

### 2. Type Safety

**Challenge:** Expressions lose Swift's type system

**Solutions:**
- Type-tagged expressions: `.binding(String, type: .string)`
- Runtime type checking in evaluator
- Server validates expressions before sending

### 3. Performance

**Challenge:** Re-evaluating expressions on every cache change

**Solutions:**
- Dependency tracking (only re-evaluate if used keys change)
- Memoization for complex expressions
- Incremental updates

---

## Testing Strategy

### Unit Tests
- Expression serialization/deserialization
- Evaluator correctness for each operator
- Type coercion edge cases
- Optional handling

### Integration Tests
- End-to-end property access
- String interpolation with multiple bindings
- Nested expressions
- Cache invalidation

### Performance Tests
- Expression evaluation latency
- Memory usage for complex expressions
- UI update frequency

---

## Related Documentation

- [State Management](STATE_MANAGEMENT.md)
- [Reactive State Cache](../Packages/ClientUI/Sources/ClientUI/ClientUI.docc/Articles/ReactiveStateCache.md)
- [Architecture](ARCHITECTURE.md)

---

## Status

- **Phase 1**: ✅ **COMPLETE** (99.5% API compatibility - see PHASE_1_GAP_ANALYSIS.md)
- **Phase 2**: ✅ **COMPLETE** (Full operator support - see PHASE_2_COMPLETE.md)
- **Phase 3**: 📋 Ready to implement
- **Phase 4**: 🧪 Experimental

Last updated: 2025-10-20

