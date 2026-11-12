require "test_helper"

class ItemTest < ActiveSupport::TestCase
  test "search matches title, description and author name" do
    assert_equal [ items(:camera) ], Item.search("polaroid").to_a
    assert_equal [ items(:book) ], Item.search("hardcover").to_a
    assert_equal [ items(:book) ], Item.search("bob").to_a
  end

  test "blank search returns everything" do
    assert_equal Item.count, Item.search("").count
  end

  test "search escapes LIKE wildcards" do
    assert_empty Item.search("%")
  end
end
