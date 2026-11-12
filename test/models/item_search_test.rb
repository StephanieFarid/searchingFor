require "test_helper"

class ItemSearchTest < ActiveSupport::TestCase
  test "highlight_html escapes user content but keeps marks" do
    html = ItemSearch.highlight_html("<script>x</script> \u0001cam\u0002era")
    assert_equal "&lt;script&gt;x&lt;/script&gt; <mark>cam</mark>era", html
    assert html.html_safe?
  end

  test "index job upserts the item" do
    ItemIndexJob.perform_now(items(:camera).id)
    doc = @typesense.documents[items(:camera).id.to_s]
    assert_equal "Vintage Polaroid camera", doc[:title]
  end

  test "index job removes deleted items" do
    ItemIndexJob.perform_now(items(:camera).id)
    id = items(:camera).id
    items(:camera).destroy
    ItemIndexJob.perform_now(id)
    assert_empty @typesense.documents
  end

  test "removing an item that was never indexed is fine" do
    assert_nothing_raised { ItemIndexJob.perform_now(-1) }
  end
end
