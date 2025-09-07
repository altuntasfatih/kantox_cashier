import Config

config :kantox_cashier, :campaigns, [
  {KantoxCashier.Campaign.BulkPurchaseCoffee,
   enabled: true, coffee_count_threshold: 3, campaigns_amount: 3.75, name: "Bulk Purchase Coffee"},
  {KantoxCashier.Campaign.BulkPurchaseStrawberry,
   enabled: true,
   strawberry_count_threshold: 3,
   campaigns_amount: 0.50,
   name: "Bulk Purchase Strawberry"},
  {KantoxCashier.Campaign.BuyOneGetOneFreeGreentea,
   enabled: true, green_tea_count_threshold: 2, name: "Buy One Get One Free Green Tea"}
]

config :kantox_cashier, :products, [
  {:CF1, 11.23},
  {:SR1, 5.0},
  {:GR1, 3.11}
]
