import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// A macro that makes a class remotely observable for ServerUI.
///
/// This macro generates the ServerUIObservable protocol methods automatically
/// by inspecting the class's property declarations.
///
/// The key insight: We don't transform existing properties - we just generate
/// the helper methods that make them observable!
public struct ObservableMacro: MemberMacro, MemberAttributeMacro, ExtensionMacro {
    
    // MARK: - ExtensionMacro
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Add RemotelyObservable conformance
        let ext: DeclSyntax = """
            extension \(type.trimmed): RemotelyObservable {}
            """
        
        return [ext.cast(ExtensionDeclSyntax.self)]
    }
    
    // MARK: - MemberAttributeMacro
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        // We don't add attributes to members
        return []
    }
    
    // MARK: - MemberMacro
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        // Ensure this is a class
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw MacroError.notAClass
        }
        
        // Extract var properties (don't transform them, just read them!)
        let properties = classDecl.memberBlock.members.compactMap { member -> PropertyInfo? in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  varDecl.bindingSpecifier.tokenKind == .keyword(.var),
                  let binding = varDecl.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
                return nil
            }
            
            let name = identifier.identifier.text
            let type = binding.typeAnnotation?.type
            
            return PropertyInfo(name: name, type: type)
        }
        
        var members: [DeclSyntax] = []
        
        // 1. Generate unique object ID
        members.append("""
            private let _objectID: String = UUID().uuidString
            """)
        
        // 2. Generate _getObjectID() method
        members.append("""
            public func _getObjectID() -> String {
                return _objectID
            }
            """)
        
        // 3. Generate _getProperties() method
        var propertiesDictElements: [String] = []
        for property in properties {
            propertiesDictElements.append("\"\(property.name)\": \(property.name)")
        }
        let propertiesDict = propertiesDictElements.joined(separator: ", ")
        
        members.append("""
            public func _getProperties() -> [String: Any] {
                return [\(raw: propertiesDict)]
            }
            """)
        
        // 4. Generate _updateProperty(name:value:) method
        var updateCases: [String] = []
        for property in properties {
            if let type = property.type {
                let typeStr = type.description.trimmingCharacters(in: .whitespaces)
                
                if typeStr == "String" {
                    updateCases.append("""
                        case "\(property.name)":
                            if let stringValue = value as? String {
                                self.\(property.name) = stringValue
                            }
                        """)
                } else if typeStr == "Int" {
                    updateCases.append("""
                        case "\(property.name)":
                            if let intValue = value as? Int {
                                self.\(property.name) = intValue
                            } else if let stringValue = value as? String, let intValue = Int(stringValue) {
                                self.\(property.name) = intValue
                            }
                        """)
                } else if typeStr == "Double" {
                    updateCases.append("""
                        case "\(property.name)":
                            if let doubleValue = value as? Double {
                                self.\(property.name) = doubleValue
                            } else if let stringValue = value as? String, let doubleValue = Double(stringValue) {
                                self.\(property.name) = doubleValue
                            }
                        """)
                } else if typeStr == "Bool" {
                    updateCases.append("""
                        case "\(property.name)":
                            if let boolValue = value as? Bool {
                                self.\(property.name) = boolValue
                            } else if let stringValue = value as? String {
                                self.\(property.name) = (stringValue.lowercased() == "true")
                            }
                        """)
                } else {
                    // Generic case - just try to cast
                    updateCases.append("""
                        case "\(property.name)":
                            if let typedValue = value as? \(type) {
                                self.\(property.name) = typedValue
                            }
                        """)
                }
            }
        }
        
        let updateSwitch = updateCases.joined(separator: "\n        ")
        
        members.append("""
            public func _updateProperty(name: String, value: Any) {
                switch name {
                \(raw: updateSwitch)
                default:
                    break
                }
            }
            """)
        
        return members
    }
}

/// Information about a property in the class.
struct PropertyInfo {
    let name: String
    let type: TypeSyntax?
}

/// Errors that can be thrown by the macro.
enum MacroError: Error, CustomStringConvertible {
    case notAClass
    
    var description: String {
        switch self {
        case .notAClass:
            return "@RemotelyObservable can only be applied to classes"
        }
    }
}
