import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// A macro that makes a class remotely observable for ServerUI.
///
/// This macro generates the RemotelyObservable protocol methods automatically
/// by inspecting the class's property declarations.
///
/// ## What It Does
///
/// ```swift
/// @RemotelyObservable
/// class Profile {
///     var name: String = "John"
///     var age: Int = 30
/// }
/// ```
///
/// The macro generates:
/// - `_objectID`: Unique identifier for the instance
/// - `_getObjectID()`: Returns the unique ID
/// - `_getProperties()`: Returns all properties as a dictionary
/// - `_updateProperty(name:value:)`: Updates a property by name
///
/// ## Usage
///
/// ```swift
/// @State var profile = Profile()
/// 
/// // Bindings work automatically:
/// TextField("Name", text: $profile.name)
/// 
/// // For instant-update text display:
/// Text(binding: $profile.name)
/// ```
///
/// ## Note on Property Transformation
///
/// Due to Swift macro limitations, we cannot transform existing properties into
/// `ObservableProperty` wrappers automatically. Instead, the macro generates
/// protocol methods that work with your properties as-is.
///
/// For string interpolation with instant updates, use:
/// ```swift
/// Text(binding: $profile.name)  // ← Instant updates
/// ```
///
/// Phase 2 may explore accessor macros for seamless `Text("\(profile.name)")` syntax.
public struct ObservableMacro: MemberMacro, ExtensionMacro {
    
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
        
        // Extract var properties (read only, don't transform!)
        let properties = classDecl.memberBlock.members.compactMap { member -> PropertyInfo? in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  varDecl.bindingSpecifier.tokenKind == .keyword(.var),
                  let binding = varDecl.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
                return nil
            }
            
            let name = identifier.identifier.text
            
            // Skip properties that start with underscore
            guard !name.hasPrefix("_") else {
                return nil
            }
            
            // Extract type
            var typeString: String?
            if let typeAnnotation = binding.typeAnnotation {
                typeString = typeAnnotation.type.description.trimmingCharacters(in: .whitespaces)
            }
            
            return PropertyInfo(name: name, typeString: typeString)
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
            if let typeString = property.typeString {
                if typeString == "String" {
                    updateCases.append("""
                        case "\(property.name)":
                            if let stringValue = value as? String {
                                self.\(property.name) = stringValue
                            }
                        """)
                } else if typeString == "Int" {
                    updateCases.append("""
                        case "\(property.name)":
                            if let intValue = value as? Int {
                                self.\(property.name) = intValue
                            } else if let stringValue = value as? String, let intValue = Int(stringValue) {
                                self.\(property.name) = intValue
                            }
                        """)
                } else if typeString == "Double" {
                    updateCases.append("""
                        case "\(property.name)":
                            if let doubleValue = value as? Double {
                                self.\(property.name) = doubleValue
                            } else if let stringValue = value as? String, let doubleValue = Double(stringValue) {
                                self.\(property.name) = doubleValue
                            }
                        """)
                } else if typeString == "Bool" {
                    updateCases.append("""
                        case "\(property.name)":
                            if let boolValue = value as? Bool {
                                self.\(property.name) = boolValue
                            } else if let stringValue = value as? String {
                                self.\(property.name) = (stringValue.lowercased() == "true")
                            }
                        """)
                } else {
                    // Generic case
                    updateCases.append("""
                        case "\(property.name)":
                            if let typedValue = value as? \(typeString) {
                                self.\(property.name) = typedValue
                            }
                        """)
                }
            } else {
                // No type annotation - try generic cast
                updateCases.append("""
                    case "\(property.name)":
                        self.\(property.name) = value as! \(property.name).Type
                    """)
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
    let typeString: String?
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
