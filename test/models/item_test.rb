require "test_helper"

class ItemTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "fallback search matches title and description" do
    assert_equal [ items(:camera) ], Item.search("polaroid").to_a
    assert_equal [ items(:book) ], Item.search("hardcover").to_a
  end

  test "blank search returns everything" do
    assert_equal Item.count, Item.search("").count
  end

  test "search escapes LIKE wildcards" do
    assert_empty Item.search("%")
  end

  test "saving enqueues a search index sync" do
    assert_enqueued_with(job: ItemIndexJob) { Item.create!(title: "a bike") }
  end
end
