defmodule KantoxCashier.ShoppingCart.CartProcessor do
  @moduledoc """
  Handles cart business logic including pricing calculations,
  discount application, and campaign management.
  """

  alias KantoxCashier.ShoppingCart.Cart
  alias KantoxCashier.Product

  def create_shopping_cart(user_id) when is_integer(user_id) do
    Cart.new(user_id)
  end

  @doc """
  Adds an item to the cart, applies campaigns, and calculates totals.
  """
  def add_item(cart, product_code) do
    Cart.add_product(cart, Product.new(product_code))
    |> apply_campaigns()
    |> checkout()
  end

  @doc """
  Removes an item from the cart.
  """
  def remove_item(cart, product_code) do
    Cart.remove_product(cart, product_code)
  end

  @doc """
  Calculates the final amounts and totals for the cart.
  """
  def checkout(%Cart{products: products, discounts: discounts} = cart) do
    amount =
      products
      |> Enum.map(fn {_code, {count, %Product{price: price}}} -> count * price end)
      |> Enum.sum()

    total_discount = Enum.sum(discounts)
    total = amount - total_discount

    %Cart{cart | amount: Float.round(amount, 2), total: Float.round(total, 2)}
  end

  @doc """
  Applies all enabled campaigns to the cart.
  """
  def apply_campaigns(cart) do
    # clear previous discounts
    cart = %Cart{cart | discounts: []}

    load_campaigns()
    |> Enum.reduce(cart, fn campaign, cart ->
      campaign.apply(cart)
    end)
  end

  @doc """
  Loads all enabled campaigns.
  """
  def load_campaigns do
    [
      KantoxCashier.Campaign.BulkPurchaseCoffee,
      KantoxCashier.Campaign.BulkPurchaseStrawberry,
      KantoxCashier.Campaign.BuyOneGetOneFreeGreentea
    ]
    |> Enum.filter(fn c -> c.enabled?() end)
  end
end
