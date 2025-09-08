# KantoxCashier

A shopping cart system with campaign 

## Features

- **Shopping Cart Management**: Add/remove items, calculate totals
- **Campaign System**: Automatic discount application (BOGO, bulk purchase)
- **Item Catalog**: Coffee, Green Tea, Strawberry with configurable pricing
- **Cart Preview**: Detailed breakdown of items, campaigns, and totals

## Usage

```elixir
# Create and manage shopping carts
user_id = 123

# Add items to cart
KantoxCashier.add_item(user_id, :CF1)  # Coffee
KantoxCashier.add_item(user_id, :GR1)  # Green Tea
KantoxCashier.add_item(user_id, :SR1)  # Strawberry

# Remove items
KantoxCashier.remove_item(user_id, :CF1)

# Preview cart with campaign summary
KantoxCashier.preview(user_id)

# Get current state of cart 
KantoxCashier.get_cart(user_id)
```

## Available Campaigns

- **Buy One Get One Free Green Tea**: Get second green tea free
- **Bulk Purchase Coffee**: Discount on 3+ coffee items  
- **Bulk Purchase Strawberry**: Discount on 3+ strawberry items
