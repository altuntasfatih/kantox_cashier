defmodule KantoxCashier.ShoppingCart.CartProcessor do
  alias KantoxCashier.Product
  alias KantoxCashier.ShoppingCart.Cart

  def create_shopping_cart(user_id) when is_integer(user_id) do
    Cart.new(user_id)
  end

  def add_item(cart, product_code) do
    Cart.add_product(cart, Product.new(product_code))
    |> apply_campaigns()
    |> checkout()
  end

  def remove_item(cart, product_code) do
    Cart.remove_product(cart, product_code)
    |> apply_campaigns()
    |> checkout()
  end

  def checkout(%Cart{products: products, discounts: discounts} = cart) do
    amount =
      products
      |> Enum.map(fn {_code, {count, %Product{price: price}}} -> count * price end)
      |> Enum.sum()

    total_discount = Enum.sum(discounts)
    total = amount - total_discount

    %Cart{cart | amount: Float.round(amount, 2), total: Float.round(total, 2)}
  end

  def apply_campaigns(cart) do
    # clear previous discounts
    cart = %Cart{cart | discounts: [], total: 0.0, amount: 0.0}

    load_campaigns()
    |> Enum.reduce(cart, fn campaign, cart ->
      campaign.apply(cart)
    end)
  end

  def load_campaigns do
    [
      KantoxCashier.Campaign.BulkPurchaseCoffee,
      KantoxCashier.Campaign.BulkPurchaseStrawberry,
      KantoxCashier.Campaign.BuyOneGetOneFreeGreentea
    ]
    |> Enum.filter(fn c -> c.enabled?() end)
  end
end
