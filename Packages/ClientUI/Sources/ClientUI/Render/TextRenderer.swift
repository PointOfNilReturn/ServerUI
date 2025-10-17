import SwiftUI
import ViewSchema

/// Extension to create SwiftUI Text views from TextSpec.
///
/// This extension handles the conversion from ServerUI's TextSpec to SwiftUI's Text,
/// preserving the original initializer's intent (localized, verbatim, markdown, dates, etc.).
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
            // Create formatted date text
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
        }
    }
}

/// Extension to convert TextDateStyle to SwiftUI's Text.DateStyle.
extension TextDateStyle {
    /// Converts a TextDateStyle to SwiftUI's Text.DateStyle.
    var toSwiftUI: Text.DateStyle {
        switch self {
        case .time:
            return .time
        case .date:
            return .date
        case .relative:
            return .relative
        case .offset:
            return .offset
        case .timer:
            return .timer
        }
    }
}
