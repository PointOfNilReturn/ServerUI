import Foundation
import ViewSchema

/// A view that displays one or more lines of read-only text.
///
/// `Text` is a primitive view that renders textual content. It can be styled using
/// modifiers like `.font()` to adjust its appearance.
///
/// ## Initializers
///
/// `Text` provides multiple initializers that correspond to SwiftUI's Text API:
///
/// ```swift
/// // Localized string (will be translated if .strings file exists)
/// Text("greeting.hello")
///
/// // Verbatim string (rendered as-is, no localization)
/// Text(verbatim: "©2024 Acme Corp")
///
/// // Markdown formatting (iOS 15+)
/// Text(markdown: "**Bold** and *italic*")
///
/// // Date formatting
/// Text(Date(), style: .relative)  // "2 hours ago"
///
/// // Date range
/// Text(startDate...endDate)  // "Jan 1 - Jan 5, 2024"
///
/// // Timer (iOS 14+)
/// Text(timerInterval: Date()...Date().addingTimeInterval(60))  // "1:00"
/// ```
///
/// ## Localization
///
/// By default, `Text(_:)` treats the string as a localization key. Use `Text(verbatim:)`
/// when you want to display a literal string without localization lookup.
///
/// ## Date and Time Formatting
///
/// Text can automatically format dates and times based on the user's locale and preferences.
/// The formatting happens on the client, ensuring correct localization.
///
/// ## Encoding
///
/// Text views are encoded as `ViewNode` instances with type `.text(TextSpec)`. The
/// `TextSpec` enum preserves which initializer was used, ensuring the client can
/// render the text with the correct behavior.
///
/// ## Modifiers
///
/// Currently supported modifiers:
/// - `.font(_:)` - Sets the font style (largeTitle, title, headline, body, footnote, caption)
///
/// - SeeAlso: `TextSpec` for the schema definition
public struct Text: View {
    /// The specification defining the text content and rendering behavior.
    public let spec: TextSpec

    /// Creates a text view that displays a localizable string.
    ///
    /// The string is treated as a localization key. On the client, it will be
    /// looked up in the app's `.strings` files based on the user's locale.
    ///
    /// ```swift
    /// Text("greeting.hello")  // Looks up "greeting.hello" in Localizable.strings
    /// ```
    ///
    /// - Parameter content: The localizable string to display.
    public init(_ content: String) {
        spec = .localized(content)
    }
    
    /// Creates a text view that displays a literal string without localization.
    ///
    /// The string is rendered exactly as provided, without any localization lookup.
    /// Use this for strings that should never be translated, like:
    /// - Copyright notices
    /// - Brand names
    /// - Code snippets
    /// - Version numbers
    ///
    /// ```swift
    /// Text(verbatim: "©2024 Acme Corp")  // Rendered as-is
    /// ```
    ///
    /// - Parameter content: The literal string to display.
    public init(verbatim content: String) {
        spec = .verbatim(content)
    }
    
    /// Creates a text view that displays markdown-formatted content.
    ///
    /// The markdown string is parsed on the client and can include:
    /// - **Bold** - `**text**`
    /// - *Italic* - `*text*`
    /// - [Links](url) - `[text](url)`
    /// - `Code` - `` `text` ``
    /// - And more
    ///
    /// ```swift
    /// Text(markdown: "**Important:** Read the [docs](https://example.com)")
    /// ```
    ///
    /// - Parameter markdown: The markdown-formatted string to display.
    @available(iOS 15, macOS 12, *)
    public init(markdown: String) {
        spec = .markdown(markdown)
    }
    
    /// Creates a text view that displays a formatted date.
    ///
    /// The date is formatted on the client according to the user's locale and
    /// the specified style.
    ///
    /// ```swift
    /// Text(Date(), style: .time)      // "3:30 PM"
    /// Text(Date(), style: .date)      // "January 1, 2024"
    /// Text(Date(), style: .relative)  // "2 hours ago"
    /// Text(Date(), style: .offset)    // "2h ago" (live updating)
    /// Text(Date(), style: .timer)     // "1:23:45" (elapsed time)
    /// ```
    ///
    /// - Parameters:
    ///   - date: The date to display.
    ///   - style: The formatting style to use.
    public init(_ date: Date, style: TextDateStyle) {
        spec = .dateStyled(date, style)
    }
    
    /// Creates a text view that displays a range between two dates.
    ///
    /// The date range is formatted on the client according to the user's locale,
    /// typically as "Jan 1 - Jan 5, 2024" or similar.
    ///
    /// ```swift
    /// let start = Date()
    /// let end = start.addingTimeInterval(3600 * 24 * 7)
    /// Text(start...end)  // "Jan 1 - Jan 8, 2024"
    /// ```
    ///
    /// - Parameter dateRange: A closed range of dates to display.
    public init(_ dateRange: ClosedRange<Date>) {
        spec = .dateRange(start: dateRange.lowerBound, end: dateRange.upperBound)
    }
    
    /// Creates a text view that displays a live-updating timer.
    ///
    /// The timer counts down (or up) from the start date to the end date,
    /// updating automatically. Optionally, you can pause the timer at a specific time.
    ///
    /// ```swift
    /// // Countdown timer
    /// let now = Date()
    /// let future = now.addingTimeInterval(60)
    /// Text(timerInterval: now...future)  // "1:00", "0:59", "0:58"...
    ///
    /// // Paused timer
    /// Text(timerInterval: now...future, pauseTime: now.addingTimeInterval(30))
    /// ```
    ///
    /// - Parameters:
    ///   - timerInterval: The date range for the timer.
    ///   - pauseTime: Optional date at which to pause the timer.
    @available(iOS 14, macOS 11, *)
    public init(timerInterval: ClosedRange<Date>, pauseTime: Date? = nil) {
        spec = .timerInterval(
            start: timerInterval.lowerBound,
            end: timerInterval.upperBound,
            pauseTime: pauseTime
        )
    }
    
    /// Text is a primitive view, so its body is EmptyView.
    public var body: EmptyView { EmptyView() }
}
