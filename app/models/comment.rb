class Comment < ApplicationRecord
  belongs_to :item, counter_cache: true

  validates :body, presence: true, length: { maximum: 2000 }
end
