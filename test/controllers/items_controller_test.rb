require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  test "home page lists posts and has the create-post pop-up" do
    get root_path
    assert_response :success
    assert_match "Vintage Polaroid camera", response.body
    assert_select "button[data-action='modal#open']", "Create a post"
    assert_select "dialog form[action='#{items_path}']" do
      assert_select "label", /I'm searching for/
      assert_select "input[name='item[title]'][required]"
    end
  end

  test "search uses Typesense results, in Typesense's order, with highlights" do
    @typesense.returns([ items(:book), items(:camera) ], snippets: { items(:book) => "First \u0001edit\u0002ion novel" })

    get items_path(q: "editon")
    assert_response :success
    assert_select "#items > a", 2
    assert_select "#items > a:first-child h2 mark", "edit"
    assert_select "#items > a:last-child h2", "Searching for Vintage Polaroid camera"
  end

  test "search falls back to SQL when Typesense is down" do
    @typesense.error = Faraday::ConnectionFailed.new("connection refused")

    get items_path(q: "novel")
    assert_response :success
    assert_match "First edition novel", response.body
    assert_no_match "Vintage Polaroid camera", response.body
  end

  test "anyone can view a post" do
    get item_path(items(:camera))
    assert_response :success
    assert_match "Try the flea market", response.body
  end

  test "anyone can create a post anonymously" do
    assert_difference("Item.count") do
      assert_enqueued_with(job: ItemIndexJob) do
        post items_path, params: { item: { title: "a rare stamp", description: "1918 Inverted Jenny" } }
      end
    end
    assert_redirected_to item_path(Item.last)
  end

  test "blank post is rejected" do
    assert_no_difference("Item.count") do
      post items_path, params: { item: { title: "" } }, headers: { "HTTP_REFERER" => root_url }
    end
    assert_redirected_to root_url
    assert_equal "Title can't be blank", flash[:alert]
  end

  test "posts cannot be edited or deleted" do
    patch item_path(items(:book)), params: { item: { title: "hijacked" } }
    assert_response :not_found
    delete item_path(items(:book))
    assert_response :not_found
    assert_equal "First edition novel", items(:book).reload.title
  end
end
