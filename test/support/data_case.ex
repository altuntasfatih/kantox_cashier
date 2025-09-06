defmodule KantoxCashier.DataCase do
  use ExUnit.CaseTemplate

  alias KantoxCashier.Product
  alias KantoxCashier.ShoppingCart.Cart

  using do
    quote do
      alias KantoxCashier.Campaign.BulkPurchaseCoffee
      alias KantoxCashier.Campaign.BulkPurchaseStrawberry
      alias KantoxCashier.Campaign.BuyOneGetOneFreeGreentea

      alias KantoxCashier.Product
      alias KantoxCashier.ShoppingCart.Cart

      import KantoxCashier.DataCase
    end
  end

  setup do
    on_exit(fn ->
      DynamicSupervisor.which_children(KantoxCashier.ShoppingCart.CartSupervisor)
      |> Enum.each(fn {_, pid, _, _} ->
        DynamicSupervisor.terminate_child(KantoxCashier.ShoppingCart.CartSupervisor, pid)
      end)
    end)
  end

  def create_shopping_cart(user_id \\ 1), do: Cart.new(user_id)

  def add_greentea_to_cart(cart, count \\ 1) do
    Enum.reduce(1..count, cart, fn _, cart ->
      Cart.add_product(
        cart,
        Product.green_tea()
      )
    end)
  end

  def add_strawberry_to_cart(cart, count \\ 1) do
    Enum.reduce(1..count, cart, fn _, cart ->
      Cart.add_product(
        cart,
        Product.strawberry()
      )
    end)
  end

  def add_coffee_to_cart(cart, count \\ 1) do
    Enum.reduce(1..count, cart, fn _, cart ->
      Cart.add_product(
        cart,
        Product.coffee()
      )
    end)
  end
end
