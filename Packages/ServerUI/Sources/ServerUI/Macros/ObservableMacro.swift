/// A macro that makes a class remotely observable in ServerUI.
///
/// Apply this macro to a class to automatically generate all the boilerplate needed
/// for observable objects. The macro reads your property declarations and generates
/// the three required methods.
///
/// ## Usage
///
/// ```swift
/// @RemotelyObservable
/// class UserProfile: @unchecked Sendable {
///     var name: String = ""
///     var email: String = ""
///     var age: Int = 0
/// }
/// // That's it! All methods generated automatically.
/// ```
///
/// ## Generated Code
///
/// The macro generates:
/// - `_objectID`: Unique identifier for the instance
/// - `_getObjectID()`: Returns the unique ID
/// - `_getProperties()`: Returns all properties as a dictionary
/// - `_updateProperty(name:value:)`: Updates a property by name with type-safe casting
///
/// ## Usage with @State
///
/// Like vanilla SwiftUI, use `@State` (not `@StateObject`):
///
/// ```swift
/// struct MyView: View {
///     @State private var profile = UserProfile()
///     
///     var body: some View {
///         ProfileEditor(profile: profile)
///     }
/// }
/// ```
///
/// ## Usage with @Bindable
///
/// ```swift
/// struct ProfileEditor: View {
///     @Bindable var profile: UserProfile
///     
///     var body: some View {
///         TextField("Name", text: $profile.name)
///         TextField("Email", text: $profile.email)
///     }
/// }
/// ```
///
/// ## Generated Members
///
/// The macro automatically generates:
/// - Backing storage for each property (e.g., `_name`, `_email`)
/// - Computed properties with change tracking
/// - `_objectID`: A unique identifier for the object instance
/// - `_getObjectID()`: Returns the unique object ID
/// - `_getProperties()`: Returns all properties as a dictionary (for serialization)
/// - `_updateProperty(name:value:)`: Updates a property by name (for remote updates)
///
/// ## Sendable Conformance
///
/// For Swift 6 concurrency, add `@unchecked Sendable` conformance:
///
/// ```swift
/// @RemotelyObservable
/// class UserProfile: @unchecked Sendable {
///     var name: String = ""
/// }
/// ```
///
/// ## Usage with @State and @Bindable
///
/// Like vanilla SwiftUI's `@Observable`, you use `@State` (not `@StateObject`):
///
/// ```swift
/// struct MyView: View {
///     @State private var profile = UserProfile()  // ← @State for objects!
///     
///     var body: some View {
///         ProfileEditor(profile: $profile)
///     }
/// }
///
/// struct ProfileEditor: View {
///     @Bindable var profile: UserProfile
///     
///     var body: some View {
///         TextField("Name", text: $profile.name)
///         TextField("Email", text: $profile.email)
///     }
/// }
/// ```
///
/// - SeeAlso: `@State`, `@Bindable`, `ObservableStore`
@attached(member, names: arbitrary)
@attached(extension, conformances: RemotelyObservable)
public macro RemotelyObservable() = #externalMacro(module: "ServerUIMacros", type: "ObservableMacro")
