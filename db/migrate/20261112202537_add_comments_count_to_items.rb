class AddCommentsCountToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :comments_count, :integer, default: 0, null: false
  end
end
