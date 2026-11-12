require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  test "anyone can comment anonymously" do
    assert_difference -> { items(:camera).reload.comments_count } do
      post item_comments_path(items(:camera)), params: { comment: { body: "eBay has a few" } }
    end
    assert_redirected_to item_path(items(:camera), anchor: ActionView::RecordIdentifier.dom_id(Comment.last))
  end

  test "blank comment is rejected" do
    assert_no_difference("Comment.count") do
      post item_comments_path(items(:camera)), params: { comment: { body: "" } }
    end
    assert_redirected_to item_path(items(:camera))
  end
end
