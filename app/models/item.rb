class Item < ApplicationRecord
  belongs_to :user
  has_many :comments, -> { order(:created_at) }, dependent: :destroy

  validates :title, presence: true, length: { maximum: 150 }

  scope :search, ->(query) {
    next all if query.blank?

    pattern = "%#{sanitize_sql_like(query.strip)}%"
    left_joins(:user)
      .where("items.title LIKE :q OR items.description LIKE :q OR users.name LIKE :q", q: pattern)
  }
end
