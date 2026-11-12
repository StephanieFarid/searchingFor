require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  test "anyone can browse and search" do
    get root_path
    assert_response :success
    assert_match "Vintage Polaroid camera", response.body

    get items_path(q: "novel")
    assert_response :success
    assert_match "First edition novel", response.body
    assert_no_match "Vintage Polaroid camera", response.body
  end

  test "anyone can view an item" do
    get item_path(items(:camera))
    assert_response :success
    assert_match "Try the flea market", response.body
  end

  test "posting requires sign in" do
    get new_item_path
    assert_redirected_to new_session_path
  end

  test "signed in user can post" do
    sign_in_as users(:one)
    assert_difference("Item.count") do
      post items_path, params: { item: { title: "A rare stamp", description: "1918 Inverted Jenny" } }
    end
    assert_equal users(:one), Item.last.user
    assert_redirected_to item_path(Item.last)
  end

  test "cannot edit someone else's item" do
    sign_in_as users(:one)
    patch item_path(items(:book)), params: { item: { title: "hijacked" } }
    assert_response :not_found
    assert_equal "First edition novel", items(:book).reload.title
  end

  test "owner can delete item" do
    sign_in_as users(:one)
    assert_difference("Item.count", -1) { delete item_path(items(:camera)) }
  end
end
