namespace :typesense do
  desc "Recreate the Typesense items collection and index every item"
  task reindex: :environment do
    ItemSearch.reindex_all!
    puts "Indexed #{Item.count} items into Typesense."
  end
end
