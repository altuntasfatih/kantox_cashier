defmodule KantoxCashier.DataCase do
  use ExUnit.CaseTemplate

  alias KantoxCashier.ShoppingCart.Cart
  alias KantoxCashier.Product

  using do
    quote do
      alias KantoxCashier.ShoppingCart.Cart
      alias KantoxCashier.Product
      import KantoxCashier.DataCase
    end
  end

  def create_shoping_cart(user_id \\ 1), do: Cart.new(user_id)

  def add_greentea(cart, count \\ 1) do
    Enum.reduce(1..count, cart, fn _, cart ->
      Cart.add_product(
        cart,
        Product.new(Product.green_tea())
      )
    end)
  end

  def add_strawberry(cart, count \\ 1) do
    Enum.reduce(1..count, cart, fn _, cart ->
      Cart.add_product(
        cart,
        Product.new(Product.strawbery())
      )
    end)
  end

  def add_coffee(cart, count \\ 1) do
    Enum.reduce(1..count, cart, fn _, cart ->
      Cart.add_product(
        cart,
        Product.new(Product.coffee())
      )
    end)
  end
end
