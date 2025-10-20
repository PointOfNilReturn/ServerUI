import Foundation
import ServerUI

/// Demo showcasing remotely observable objects with @RemotelyObservable macro.
///
/// Just add `@RemotelyObservable` and declare your properties - all the boilerplate
/// is generated automatically by the macro!
///
/// Note: Like modern SwiftUI, we use @State (not @StateObject) for observable objects.
@RemotelyObservable
class UserProfile: @unchecked Sendable {
    var name: String = "John Doe"
    var email: String = "john.doe@example.com"
    var age: Int = 18
    var bio: String = "Software developer"
}
// All the protocol methods are generated automatically! ✨

private struct ObservableDemoScreen: View {
    @State private var profile = UserProfile()  // ← @State for objects!
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Observable Objects Demo")
                    .font(.largeTitle)
                
                Text("This demo shows observable objects with @Bindable and @State, mirroring vanilla SwiftUI!")
                    .font(.caption)
                
                // The form with bindings
                ProfileForm(profile: profile)
                
                Text("---").padding()
                
            // Display current values (pass with @Bindable for instant updates)
            ProfileDisplay(profile: profile)
                
                // Actions
                VStack(spacing: 10) {
                    Button("Reset Profile") {
                        profile.name = ""
                        profile.email = ""
                        profile.age = 18
                        profile.bio = ""
                    }
                    
                    Button("Set Example Data") {
                        profile.name = "Alice Johnson"
                        profile.email = "alice@example.com"
                        profile.age = 28
                        profile.bio = "Software engineer passionate about server-driven UI"
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Observable Demo")
    }
}

/// Form that uses @Bindable to create bindings to observable properties.
private struct ProfileForm: View {
    @Bindable var profile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Edit Profile")
                .font(.headline)
            
            // TextField automatically works with @Bindable bindings!
            TextField("Name", text: $profile.name)
            TextField("Email", text: $profile.email)
            TextField("Bio", text: $profile.bio)
            
            // For now, age is display-only (no number input yet)
            Text("Age: \(profile.age)")
                .font(.body)
        }
        .padding()
    }
}

/// Display component showing current profile values.
///
/// This demonstrates the **Expression System** (Phase 1):
/// - String interpolation with `$` captures bindings automatically
/// - Client evaluates using `ExpressionEvaluator`
/// - Values read from `ReactiveStateCache`
/// - Updates are instant (0ms latency)
private struct ProfileDisplay: View {
    @Bindable var profile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Current Values (Expression-Based)")
                .font(.headline)
            
            // Phase 1: String interpolation with $ captures bindings!
            // Updates INSTANTLY as you type! ⚡️
            Text("Name: \($profile.name)")
                .font(.body)
            
            Text("Email: \($profile.email)")
                .font(.body)
            
            Text("Bio: \($profile.bio)")
                .font(.body)
            
            // For now, age uses baked value (Int interpolation not yet optimized)
            Text("Age: \(profile.age)")
                .font(.body)
            
            Text("✨ All text above updates INSTANTLY as you type!")
                .font(.caption)
            
            Text("Clean syntax: Text(\"\\($profile.name)\")")
                .font(.caption)
        }
        .padding()
    }
}

enum ObservableDemoHandler {
    static func response() -> Data {
        let view = ObservableDemoScreen()
        guard let json = try? ServerUIJSON.encode(view) else {
            let errorBody = Data(#"{ "error": "encoding failed" }"#.utf8)
            return HTTP.buildResponse(status: "500 Internal Server Error", body: errorBody)
        }
        return HTTP.buildResponse(body: json)
    }
}

