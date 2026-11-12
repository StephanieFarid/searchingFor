alice = User.find_or_create_by!(email_address: "alice@example.com") { |u| u.name = "Alice"; u.password = "password" }
bob   = User.find_or_create_by!(email_address: "bob@example.com")   { |u| u.name = "Bob";   u.password = "password" }

if Item.none?
  camera = alice.items.create!(title: "Vintage Polaroid SX-70", description: "Working condition, budget around $150. Anywhere in the Bay Area.")
  bob.items.create!(title: "Out-of-print copy of 'The Dispossessed' (1974 first edition)", description: "Hardcover preferred.")
  alice.items.create!(title: "Replacement lid for a Le Creuset 26cm Dutch oven", description: "Mine cracked. Color doesn't matter.")
  camera.comments.create!(user: bob, body: "Check the camera swap meet on Saturdays — saw a couple there last month.")
end
