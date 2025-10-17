import SwiftUI
import ViewSchema

/// Extensions for applying view modifiers to rendered views.
///
/// This file contains the logic for converting server-side modifier specifications
/// into native SwiftUI modifiers. Each modifier type has its own application method.

extension ViewRenderer {
    /// Applies a list of modifiers to a view in order.
    ///
    /// Modifiers are applied sequentially using `reduce`, which maintains the correct
    /// order of application. This is important because modifier order affects the final result.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Modifiers: [font(.body), padding(20), frame(width: 200)]
    /// // Applied as: view.font(.body).padding(20).frame(width: 200)
    /// ```
    ///
    /// - Parameters:
    ///   - view: The base view to apply modifiers to.
    ///   - modifiers: The list of modifiers to apply in order.
    /// - Returns: The view with all modifiers applied.
    @ViewBuilder
    func applyModifiers<V: View>(to view: V, modifiers: [Modifier]) -> some View {
        modifiers.reduce(AnyView(view)) { currentView, modifier in
            switch modifier {
            case .font(let role):
                return AnyView(currentView.font(role.toSwiftUI))
                
            case .padding(let spec):
                return AnyView(applyPadding(to: currentView, spec: spec))
                
            case .frame(let spec):
                return AnyView(applyFrame(to: currentView, spec: spec))
            }
        }
    }
    
    // MARK: - Padding
    
    /// Applies padding to a view based on the padding specification.
    ///
    /// Handles three variants:
    /// - **all**: Default padding on all edges
    /// - **amount**: Custom padding amount on all edges
    /// - **edges**: Custom padding on specific edges with optional amount
    ///
    /// - Parameters:
    ///   - view: The view to add padding to.
    ///   - spec: The padding specification.
    /// - Returns: The view with padding applied.
    @ViewBuilder
    private func applyPadding<V: View>(to view: V, spec: PaddingSpec) -> some View {
        switch spec {
        case .all:
            view.padding()
            
        case .amount(let amount):
            view.padding(CGFloat(amount))
            
        case .edges(let edges, let amount):
            if let amount = amount {
                view.padding(edges.toSwiftUI, CGFloat(amount))
            } else {
                view.padding(edges.toSwiftUI)
            }
        }
    }
    
    // MARK: - Frame
    
    /// Applies frame dimensions to a view based on the frame specification.
    ///
    /// Handles two variants:
    /// - **fixed**: Sets exact width/height with optional alignment
    /// - **flexible**: Sets min/ideal/max constraints with optional alignment
    ///
    /// - Parameters:
    ///   - view: The view to apply the frame to.
    ///   - spec: The frame specification.
    /// - Returns: The view with the frame applied.
    @ViewBuilder
    private func applyFrame<V: View>(to view: V, spec: FrameSpec) -> some View {
        switch spec {
        case .fixed(let width, let height, let alignment):
            view.frame(
                width: width.map { CGFloat($0) },
                height: height.map { CGFloat($0) },
                alignment: alignment?.toSwiftUI ?? .center
            )
            
        case .flexible(let minWidth, let idealWidth, let maxWidth, let minHeight, let idealHeight, let maxHeight, let alignment):
            view.frame(
                minWidth: minWidth.map { CGFloat($0) },
                idealWidth: idealWidth.map { CGFloat($0) },
                maxWidth: maxWidth.map { CGFloat($0) },
                minHeight: minHeight.map { CGFloat($0) },
                idealHeight: idealHeight.map { CGFloat($0) },
                maxHeight: maxHeight.map { CGFloat($0) },
                alignment: alignment?.toSwiftUI ?? .center
            )
        }
    }
}

