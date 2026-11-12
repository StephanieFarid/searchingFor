class Comment < ApplicationRecord
  belongs_to :item, counter_cache: true
  belongs_to :user

  validates :body, presence: true, length: { maximum: 2000 }
end
