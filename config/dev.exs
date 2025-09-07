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

config :kantox_cashier, :items, [
  {:CF1, price: 11.23, name: "Coffee"},
  {:SR1, price: 5.0, name: "Strawberry"},
  {:GR1, price: 3.11, name: "Green Tea"}
]
