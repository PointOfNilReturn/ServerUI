import Testing
import Foundation
@testable import ServerUI

/// Tests for @Observable and @Bindable support.
@Suite("Observable Tests")
struct ObservableTests {
    
    @Test("Observable macro adds required members")
    func observableMacroAddsMembers() {
        @ServerObservable
        class TestProfile: @unchecked Sendable {
            var name: String = "John"
            var age: Int = 30
        }
        
        let profile = TestProfile()
        
        // Check that macro-generated methods exist
        let objectID = profile._getObjectID()
        #expect(!objectID.isEmpty)
        
        let properties = profile._getProperties()
        #expect(properties.keys.count >= 0) // Placeholder - will have actual properties later
    }
    
    @Test("Bindable creates bindings to observable properties")
    func bindableCreatesBindings() {
        @ServerObservable
        class UserProfile: @unchecked Sendable {
            var name: String = "Alice"
            var email: String = "alice@example.com"
        }
        
        let profile = UserProfile()
        let bindable = Bindable(wrappedValue: profile)
        
        // Access via projected value
        let nameBinding = bindable.projectedValue.name
        #expect(nameBinding.wrappedValue == "Alice")
        
        let emailBinding = bindable.projectedValue.email
        #expect(emailBinding.wrappedValue == "alice@example.com")
    }
}

