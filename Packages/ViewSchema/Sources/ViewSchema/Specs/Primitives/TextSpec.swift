import Foundation

/// Specification for a Text view, preserving which initializer was used.
///
/// Each case corresponds to a specific Text initializer in SwiftUI, ensuring
/// that the server's intent (localized vs verbatim, attributed, date formatting, etc.) is
/// preserved when rendered on the client.
///
/// ## Initializer Mapping
///
/// - `.localized(_)` → `Text(_ content: LocalizedStringKey)` / `Text(_ content: String)`
/// - `.verbatim(_)` → `Text(verbatim content: String)`
/// - `.markdown(_)` → `Text(_ markdown: LocalizedStringKey)` (iOS 15+)
/// - `.dateStyled(_:_)` → `Text(_ date: Date, style: Text.DateStyle)`
/// - `.dateRange(_)` → `Text(_ dateRange: ClosedRange<Date>)`
/// - `.timerInterval(_:_)` → `Text(timerInterval: ClosedRange<Date>, pauseTime:)` (iOS 14+)
///
/// - SeeAlso: SwiftUI's `Text` initializers
public enum TextSpec: Codable, Sendable, Equatable, Hashable {
    /// A localized string that will be translated based on the user's locale.
    ///
    /// Corresponds to SwiftUI's `Text(_ content: String)` or `Text(_ key: LocalizedStringKey)`.
    /// The client should treat this as a localizable string.
    ///
    /// - Available: iOS 13+, macOS 10.15+
    case localized(String)
    
    /// A literal string that should not be localized.
    ///
    /// Corresponds to SwiftUI's `Text(verbatim content: String)`.
    /// The client should render this string exactly as provided, without localization.
    ///
    /// - Available: iOS 13+, macOS 10.15+
    case verbatim(String)
    
    /// A string that directly displays a state variable value.
    ///
    /// This case includes the state key, allowing the client to check the optimistic
    /// cache and provide instant updates when the state changes.
    ///
    /// For example, `Text(name)` where `name` is a @State variable.
    ///
    /// - Parameters:
    ///   - stateKey: The state key being displayed (e.g., "state_HomeScreen_7")
    ///   - fallbackValue: The server-side value to use if optimistic cache is empty
    case stateBound(stateKey: String, fallbackValue: String)
    
    /// Markdown-formatted text that will be parsed and styled.
    ///
    /// Corresponds to SwiftUI's `Text(_ markdown: LocalizedStringKey)` or `init(_ markdown: String)`.
    /// The markdown is parsed on the client and can include bold, italic, links, etc.
    ///
    /// - Available: iOS 15+, macOS 12+
    case markdown(String)
    
    /// A formatted date using the specified style.
    ///
    /// Corresponds to SwiftUI's `Text(_ date: Date, style: Text.DateStyle)`.
    /// The date is formatted on the client using the user's locale and preferences.
    ///
    /// - Available: iOS 13+, macOS 10.15+
    case dateStyled(Date, TextDateStyle)
    
    /// A range between two dates.
    ///
    /// Corresponds to SwiftUI's `Text(_ dateRange: ClosedRange<Date>)`.
    /// Displays a localized date range like "Jan 1 - Jan 5, 2024".
    ///
    /// - Available: iOS 13+, macOS 10.15+
    case dateRange(start: Date, end: Date)
    
    /// A timer counting down or up from the specified interval.
    ///
    /// Corresponds to SwiftUI's `Text(timerInterval: ClosedRange<Date>, pauseTime: Date?)`.
    /// Creates a live-updating timer text.
    ///
    /// - Available: iOS 14+, macOS 11+
    case timerInterval(start: Date, end: Date, pauseTime: Date?)
}

/// Date formatting styles for Text date display.
///
/// Corresponds to SwiftUI's `Text.DateStyle`.
public enum TextDateStyle: String, Codable, Sendable, Equatable {
    /// Displays the time only (e.g., "3:30 PM")
    case time
    
    /// Displays the date only (e.g., "January 1, 2024")
    case date
    
    /// Displays relative time (e.g., "2 hours ago", "in 5 minutes")
    case relative
    
    /// Displays time relative to now, updating live (e.g., "2m ago")
    case offset
    
    /// Displays elapsed time as a timer (e.g., "1:23:45")
    case timer
}
