class ItemIndexJob < ApplicationJob
  queue_as :default
  retry_on(*ItemSearch::UNAVAILABLE, wait: :polynomially_longer, attempts: 5)

  def perform(item_id)
    if (item = Item.find_by(id: item_id))
      ItemSearch.index(item)
    else
      ItemSearch.remove(item_id)
    end
  end
end
