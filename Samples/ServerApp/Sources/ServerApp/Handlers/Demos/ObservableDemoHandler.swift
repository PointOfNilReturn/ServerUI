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
/// By using @Bindable and Text(binding:), these Text views update INSTANTLY
/// as the user types, using the optimistic cache just like the TextFields!
private struct ProfileDisplay: View {
    @Bindable var profile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Current Values")
                .font(.headline)
            
            // These Text views update INSTANTLY as you type!
            // Using Text(binding:) makes them read from the optimistic cache
            HStack {
                Text("Name: ")
                    .font(.caption)
                Text(binding: $profile.name)
                    .font(.body)
            }
            
            HStack {
                Text("Email: ")
                    .font(.caption)
                Text(binding: $profile.email)
                    .font(.body)
            }
            
            HStack {
                Text("Bio: ")
                    .font(.caption)
                Text(binding: $profile.bio)
                    .font(.body)
            }
            
            // For now, age display uses string interpolation (no binding for Int yet)
            Text("Age: \(profile.age)")
                .font(.body)
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

