//
//  UserProfileFeatureTests.swift
//  MyApp
//
//  Created by Thomas Hoang on 8/3/25.
//

import Foundation
import Testing
import ComposableArchitecture
@testable import MyApp


@MainActor
struct UserProfileFeatureTests {
    // A mock user for use in tests.
    private var user = User(id: UUID(0), name: "Thomas", email: "thomas@example.com", token: .init(value: "token-test", expiresAt: .distantFuture))
    
    @Test func testLoginButtonTapped_sendsDelegate() async {
        let userSession = UserSession(service: "test-session")
        userSession.user = nil
        // user is nil by default in a new UserSession, so no need to set it explicitly.

        let store = TestStore(initialState: UserProfileFeature.State()) {
            UserProfileFeature()
        } withDependencies: {
            $0.userSession = userSession
        }
        
        // Bắt đầu lắng nghe, nhận user là nil
        let task = await store.send(.onAppear)
        await store.receive(\.userUpdated, nil)
        
        // Giờ mới test hành động nhấn nút
        await store.send(.loginButtonTapped)
        await store.receive(\.delegate.didTapLogin)

        // Dọn dẹp: huỷ subscription khi view biến mất.
        // Điều này giả định UserProfileFeature đã được cập nhật để xử lý .onDisappear.
        await store.send(.onDisappear)
        await task.cancel()
    }
    
    @Test func testLogoutButtonTapped_success() async {
        let userSession = UserSession(service: "test-session")
        userSession.user = self.user
        
        let store = TestStore(initialState: UserProfileFeature.State()) {
            UserProfileFeature()
        } withDependencies: {
            // Ghi đè authService.logout để nó trả về thành công.
            // Nếu không, test sẽ crash vì dependency này là `unimplemented`.
            $0.authService.logout = { user in user }
            $0.userSession = userSession
        }
        
        // Bắt đầu lắng nghe, state được cập nhật với user từ session
        let task = await store.send(.onAppear)
        await store.receive(\.userUpdated, self.user) {
            $0.user = self.user
        }
        
        // Test hành động đăng xuất
        await store.send(.logoutButtonTapped) {
            $0.isLoading = true
        }
        
        // Nhận kết quả từ API
        // Sử dụng key path `\.logoutAccountResponse` vì Action không phải là Equatable.
        // Điều này cho phép chúng ta assert case và giá trị liên quan của nó.
        await store.receive(\.logoutAccountResponse, .success(self.user)) {
            // Trong closure này, chúng ta chỉ khẳng định sự thay đổi của `state`.
            // Việc `userSession.user` được set thành nil là một side effect do reducer thực hiện,
            // và chúng ta sẽ kiểm tra nó ở bên ngoài.
            $0.isLoading = false
            $0.user = nil
        }
               
        // Khẳng định rằng side effect (xoá user khỏi session) đã được reducer thực hiện.
        #expect(userSession.user == nil)

        // Reducer trả về một effect .send cho delegate action, và nó được TestStore xử lý ngay lập tức.
        await store.receive(\.delegate.didLogout)
        // Tiếp theo, subscription dài hạn từ .onAppear phát hiện sự thay đổi trong user session và gửi lại action .userUpdated.
        await store.receive(\.userUpdated, nil)

        // Dọn dẹp: huỷ subscription khi view biến mất
        await store.send(.onDisappear)
        await task.cancel()
    }
    
    @Test func testLogoutButtonTapped_failure() async {
        let error = ErrorEquatable(message: "Logout failed")
        let userSession = UserSession(service: "test-session")
        userSession.user = self.user
        
        let store = TestStore(initialState: UserProfileFeature.State()) {
            UserProfileFeature()
        } withDependencies: {
            $0.authService.logout = { _ in throw error }
            $0.userSession = userSession
        }
        
        // Bắt đầu lắng nghe, state được cập nhật với user từ session
        let task = await store.send(.onAppear)
        await store.receive(\.userUpdated, self.user) {
            $0.user = self.user
        }
        
        // Test hành động đăng xuất
        await store.send(.logoutButtonTapped) {
            $0.isLoading = true
        }
        
        // Nhận kết quả lỗi
        await store.receive(\.logoutAccountResponse, .failure(error)) {
            $0.isLoading = false
            $0.error = "Logout failed"
        }
        
        // Khẳng định user vẫn còn trong state và session
        #expect(store.state.user == self.user)
        #expect(userSession.user == self.user)

        // Dọn dẹp: huỷ subscription khi view biến mất
        await store.send(.onDisappear)
        await task.cancel()
    }
    
    @Test func testChangePasswordButtonTapped_sendsDelegate() async {
        let userSession = UserSession(service: "test-session")
        userSession.user = self.user
        
        let store = TestStore(initialState: UserProfileFeature.State()) {
            UserProfileFeature()
        } withDependencies: {
            $0.userSession = userSession
        }
        
        let task = await store.send(.onAppear)
        await store.receive(\.userUpdated, self.user) {
            $0.user = self.user
        }
        
        await store.send(.changePasswordButtonTapped)
        await store.receive(\.delegate.didTapChangePassword)

        // Dọn dẹp: huỷ subscription khi view biến mất
        await store.send(.onDisappear)
        await task.cancel()
    }
    
    @Test func testDeleteAccountButtonTapped_sendsDelegate() async {
        let userSession = UserSession(service: "test-session")
        userSession.user = self.user
        
        let store = TestStore(initialState: UserProfileFeature.State()) {
            UserProfileFeature()
        } withDependencies: {
            $0.userSession = userSession
        }
        
        let task = await store.send(.onAppear)
        await store.receive(\.userUpdated, self.user) {
            $0.user = self.user
        }
        
        await store.send(.deleteAccountButtonTapped)
        await store.receive(\.delegate.didTapDeleteAccount)

        // Dọn dẹp: huỷ subscription khi view biến mất
        await store.send(.onDisappear)
        await task.cancel()
    }
}
