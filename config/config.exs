import Config

config :kantox_cashier, :campaigns, [
  {KantoxCashier.Campaign.BulkPurchaseCoffee,
   enabled: true, count_of_coffee: 3, discount_amount: 3.75, name: "Bulk Purchase Coffee"},
  {KantoxCashier.Campaign.BulkPurchaseStrawberry,
   enabled: true, count_of_strawberry: 3, discount_amount: 0.50, name: "Bulk Purchase Strawberry"},
  {KantoxCashier.Campaign.BuyOneGetOneFreeGreentea,
   enabled: true, count_of_green_tea: 2, name: "Buy One Get One Free Green Tea"}
]

config :kantox_cashier, :products, [
  {:CF1, 11.23},
  {:SR1, 5.0},
  {:GR1, 3.11}
]
