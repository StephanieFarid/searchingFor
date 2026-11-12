require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "sign up creates a user and signs them in" do
    assert_difference("User.count") do
      post registration_path, params: { user: { name: "Carol", email_address: "carol@example.com", password: "secret123", password_confirmation: "secret123" } }
    end
    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "invalid sign up re-renders form" do
    post registration_path, params: { user: { name: "", email_address: "x@example.com", password: "a", password_confirmation: "b" } }
    assert_response :unprocessable_content
  end
end
