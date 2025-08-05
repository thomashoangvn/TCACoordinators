//
//  SettingsFeatureTests.swift
//  MyAppTests
//
//  Created by Thomas Hoang on 8/5/25.
//

import Foundation
import Testing
import ComposableArchitecture
@testable import MyApp

@MainActor
struct SettingsFeatureTests {
    // A mock user for use in tests.
    private var user = User(id: UUID(0), name: "Thomas", email: "thomas@example.com", token: .init(value: "token-test", expiresAt: .distantFuture))
    
    @Test func testUserFlow_loginAndProfileTap() async {
        // 1. Khởi tạo store với userSession ban đầu là nil (guest).
        let userSession = UserSession(service: "test-session")
        userSession.user = nil
        
        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature()
        } withDependencies: {
            $0.userSession = userSession
        }
        
        // 2. Gửi action onAppear để bắt đầu lắng nghe.
        // Store sẽ nhận được giá trị user hiện tại (nil).
        let task = await store.send(.onAppear)
        await store.receive(\.userUpdated, nil)
        
        // 3. Giả lập người dùng nhấn nút đăng nhập.
        await store.send(.loginButtonTapped)
        
        // 4. Kiểm tra delegate action được gửi đi.
        await store.receive(\.delegate.loginButtonTapped)
        
        // 5. Giả lập rằng luồng đăng nhập ở coordinator cha đã thành công
        // và cập nhật UserSession.
        userSession.user = self.user
        
        // 6. Store sẽ tự động nhận được user mới từ subscription.
        await store.receive(\.userUpdated, self.user) {
            // State.user bây giờ đã được cập nhật.
            $0.user = self.user
        }
        
        // 7. Bây giờ, khi người dùng nhấn vào profile, delegate action sẽ được gửi đi với đúng user.
        await store.send(.profileTapped)
        await store.receive(\.delegate.profileTapped)
        
        // 8. Giả lập người dùng đăng xuất từ một nơi khác trong ứng dụng.
        userSession.user = nil
        
        // 9. Store sẽ nhận được cập nhật và xoá user khỏi state.
        await store.receive(\.userUpdated, nil) {
            $0.user = nil
        }
        
        // 10. Giả lập view biến mất để huỷ subscription.
        await store.send(.onDisappear)
        await task.cancel()
    }
    
    @Test func testOnAppear_withLoggedInUser_updatesState() async {
        // 1. Giả lập user đã đăng nhập trong session.
        let userSession = UserSession(service: "test-session")
        userSession.user = self.user
        
        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature()
        } withDependencies: {
            $0.userSession = userSession
        }
        
        // 2. Gửi action onAppear.
        let task = await store.send(.onAppear)
        
        // 3. Store sẽ nhận được user từ session và cập nhật state.
        await store.receive(\.userUpdated, self.user) {
            $0.user = self.user
        }
        
        // 4. Giả lập view biến mất để huỷ subscription.
        await store.send(.onDisappear)
        await task.cancel()
    }
    
    @Test func testProfileTapped_whenLoggedOut_doesNothing() async {
        // 1. Khởi tạo store với userSession là nil (guest).
        let userSession = UserSession(service: "test-session") // user is nil by default
        userSession.user = nil
        
        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature()
        } withDependencies: {
            $0.userSession = userSession
        }
        
        // 2. Bắt đầu lắng nghe, nhận user là nil.
        let task = await store.send(.onAppear)
        await store.receive(\.userUpdated, nil)
        
        // 3. Giả lập người dùng nhấn nút profile khi chưa đăng nhập.
        await store.send(.profileTapped)
        
        // 4. Giả lập view biến mất để huỷ subscription.
        await store.send(.onDisappear)
        await task.cancel()
    }
    
    @Test func testSubscriptionIsCancelledOnDisappear() async {
        let userSession = UserSession(service: "test-session")
        userSession.user = nil
        
        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature()
        } withDependencies: {
            $0.userSession = userSession
        }
        
        // Bắt đầu lắng nghe và nhận giá trị ban đầu.
        let task = await store.send(.onAppear)
        await store.receive(\.userUpdated, nil)
        
        // 1. Giả lập view biến mất, action này sẽ kích hoạt logic huỷ subscription trong reducer.
        await store.send(.onDisappear)
        
        // 2. Giả lập một thay đổi trong UserSession *sau khi* subscription được cho là đã huỷ.
        userSession.user = self.user
        
        // 3. Vì subscription đã bị huỷ, không có action `userUpdated` nào được gửi đến store.
        // TestStore sẽ tự động xác nhận điều này. Nếu có bất kỳ action nào được nhận,
        // bài test sẽ thất bại, chứng tỏ logic huỷ của chúng ta có vấn đề.
        await task.cancel()
    }
}
