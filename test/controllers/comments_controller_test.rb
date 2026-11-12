require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  test "signed in user can comment" do
    sign_in_as users(:two)
    assert_difference -> { items(:camera).reload.comments_count } do
      post item_comments_path(items(:camera)), params: { comment: { body: "eBay has a few" } }
    end
  end

  test "commenting requires sign in" do
    assert_no_difference("Comment.count") do
      post item_comments_path(items(:camera)), params: { comment: { body: "hi" } }
    end
    assert_redirected_to new_session_path
  end

  test "only the author can delete a comment" do
    sign_in_as users(:one)
    delete item_comment_path(items(:camera), comments(:one))
    assert_response :not_found

    sign_in_as users(:two)
    assert_difference("Comment.count", -1) { delete item_comment_path(items(:camera), comments(:one)) }
  end
end
