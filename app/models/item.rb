class Item < ApplicationRecord
  has_many :comments, -> { order(:created_at) }, dependent: :destroy

  validates :title, presence: true, length: { maximum: 150 }
  validates :description, length: { maximum: 5000 }

  after_commit :sync_search_index, on: %i[create update destroy]

  # Simple SQL search, used when Typesense is unavailable.
  scope :search, ->(query) {
    next all if query.blank?

    pattern = "%#{sanitize_sql_like(query.strip)}%"
    where("title LIKE :q OR description LIKE :q", q: pattern)
  }

  private
    def sync_search_index
      ItemIndexJob.perform_later(id)
    end
end
