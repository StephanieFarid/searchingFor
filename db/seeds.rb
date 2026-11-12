if Item.none?
  camera = Item.create!(title: "a vintage Polaroid SX-70", description: "Working condition, budget around $150. Anywhere in the Bay Area.")
  Item.create!(title: "an out-of-print copy of 'The Dispossessed' (1974 first edition)", description: "Hardcover preferred.")
  Item.create!(title: "a replacement lid for a 26cm Dutch oven", description: "Mine cracked. Color doesn't matter.")
  camera.comments.create!(body: "Check the camera swap meet on Saturdays — saw a couple there last month.")
end
