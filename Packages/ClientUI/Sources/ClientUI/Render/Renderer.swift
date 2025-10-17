import SwiftUI
import ViewSchema

public struct ViewRenderer {
    public init() {}

    @ViewBuilder
    public func render(_ viewHierarchy: ViewHierarchy) -> some View {
        renderNode(viewHierarchy.root)
    }
    
    @ViewBuilder
    private func renderNode(_ node: ViewNode) -> some View {
        let baseView = renderNodeContent(node)
        
        // Apply modifiers
        applyModifiers(to: baseView, modifiers: node.modifiers)
    }
    
    @ViewBuilder
    private func renderNodeContent(_ node: ViewNode) -> some View {
        switch node.type {
        case .text(let spec):
            Text(spec)
            
        case .vstack(let spec):
            VStack(
                alignment: spec.alignment?.toSwiftUI ?? .center,
                spacing: spec.spacing.map { CGFloat($0) }
            ) {
                ForEach(Array(node.children.enumerated()), id: \.offset) { _, child in
                    renderNode(child)
                }
            }
            
        case .hstack(let spec):
            HStack(
                alignment: spec.alignment?.toSwiftUI ?? .center,
                spacing: spec.spacing.map { CGFloat($0) }
            ) {
                ForEach(Array(node.children.enumerated()), id: \.offset) { _, child in
                    renderNode(child)
                }
            }
            
        case .unknown:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func applyModifiers<V: View>(to view: V, modifiers: [Modifier]) -> some View {
        modifiers.reduce(AnyView(view)) { currentView, modifier in
            switch modifier {
            case .font(let role):
                return AnyView(currentView.font(role.toSwiftUI))
            }
        }
    }
}

// MARK: - Conversion Extensions

extension HorizontalAlignmentSpec {
    var toSwiftUI: HorizontalAlignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}

extension VerticalAlignmentSpec {
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

extension FontRole {
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
