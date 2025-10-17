import SwiftUI
import ViewSchema

/// Conversion extensions that bridge ServerUI specifications to native SwiftUI types.
///
/// This file contains all the `toSwiftUI` conversion methods that transform
/// JSON-serializable specification types into their SwiftUI equivalents.
///
/// These conversions are used throughout the rendering pipeline to translate
/// server-defined view hierarchies into native UI components.

// MARK: - Alignment Conversions

/// Converts ServerUI horizontal alignment specifications to SwiftUI's `HorizontalAlignment`.
///
/// This extension bridges the gap between the JSON-serializable `HorizontalAlignmentSpec`
/// and SwiftUI's native alignment types used in `VStack`.
///
/// - SeeAlso: `HorizontalAlignmentSpec`, `VStackSpec`
extension HorizontalAlignmentSpec {
    /// Converts this alignment spec to SwiftUI's `HorizontalAlignment`.
    ///
    /// - Returns: The corresponding SwiftUI `HorizontalAlignment` value.
    var toSwiftUI: HorizontalAlignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}

/// Converts ServerUI vertical alignment specifications to SwiftUI's `VerticalAlignment`.
///
/// This extension bridges the gap between the JSON-serializable `VerticalAlignmentSpec`
/// and SwiftUI's native alignment types used in `HStack`.
///
/// - SeeAlso: `VerticalAlignmentSpec`, `HStackSpec`
extension VerticalAlignmentSpec {
    /// Converts this alignment spec to SwiftUI's `VerticalAlignment`.
    ///
    /// - Returns: The corresponding SwiftUI `VerticalAlignment` value.
    var toSwiftUI: VerticalAlignment {
        switch self {
        case .top: return .top
        case .center: return .center
        case .bottom: return .bottom
        case .firstTextBaseline: return .firstTextBaseline
        case .lastTextBaseline: return .lastTextBaseline
        }
    }
}

/// Converts ServerUI 2D alignment specifications to SwiftUI's `Alignment`.
///
/// This extension bridges the gap between the JSON-serializable `AlignmentSpec`
/// and SwiftUI's native alignment type used for frame positioning.
///
/// - SeeAlso: `AlignmentSpec`, `FrameSpec`
extension AlignmentSpec {
    /// Converts this alignment spec to SwiftUI's `Alignment`.
    ///
    /// - Returns: The corresponding SwiftUI `Alignment` value.
    var toSwiftUI: Alignment {
        switch self {
        case .topLeading: return .topLeading
        case .top: return .top
        case .topTrailing: return .topTrailing
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        case .bottomLeading: return .bottomLeading
        case .bottom: return .bottom
        case .bottomTrailing: return .bottomTrailing
        }
    }
}

// MARK: - Edge Set Conversions

/// Converts ServerUI edge set specifications to SwiftUI's `Edge.Set`.
///
/// This extension bridges the gap between the JSON-serializable `EdgeSetSpec`
/// and SwiftUI's native edge set type used in padding modifiers.
///
/// - SeeAlso: `EdgeSetSpec`, `PaddingSpec`
extension EdgeSetSpec {
    /// Converts this edge set spec to SwiftUI's `Edge.Set`.
    ///
    /// - Returns: The corresponding SwiftUI `Edge.Set` value.
    var toSwiftUI: Edge.Set {
        switch self {
        case .all: return .all
        case .top: return .top
        case .bottom: return .bottom
        case .leading: return .leading
        case .trailing: return .trailing
        case .horizontal: return .horizontal
        case .vertical: return .vertical
        }
    }
}

// MARK: - Font Conversions

/// Converts ServerUI font roles to SwiftUI's `Font` type.
///
/// This extension bridges the gap between the JSON-serializable `FontRole`
/// and SwiftUI's native font type. Font roles map to semantic font styles
/// that automatically adapt to user settings like Dynamic Type.
///
/// - SeeAlso: `FontRole`
extension FontRole {
    /// Converts this font role to SwiftUI's `Font`.
    ///
    /// - Returns: The corresponding SwiftUI `Font` value.
    var toSwiftUI: Font {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title
        case .headline: return .headline
        case .body: return .body
        case .footnote: return .footnote
        case .caption: return .caption
        }
    }
}

// MARK: - Text Date Style Conversions

/// Converts ServerUI text date styles to SwiftUI's `Text.DateStyle`.
///
/// This extension bridges the gap between the JSON-serializable `TextDateStyle`
/// and SwiftUI's native date formatting styles for `Text` views.
///
/// - SeeAlso: `TextDateStyle`, `TextSpec`
extension TextDateStyle {
    /// Converts this date style to SwiftUI's `Text.DateStyle`.
    ///
    /// - Returns: The corresponding SwiftUI `Text.DateStyle` value.
    var toSwiftUI: Text.DateStyle {
        switch self {
        case .time: return .time
        case .date: return .date
        case .relative: return .relative
        case .offset: return .offset
        case .timer: return .timer
        }
    }
}

