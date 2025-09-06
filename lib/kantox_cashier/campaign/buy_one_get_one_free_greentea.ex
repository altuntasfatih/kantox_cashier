defmodule KantoxCashier.Campaign.BuyOneGetOneFreeGreentea do
  @behaviour KantoxCashier.Campaign.Behaviour

  alias KantoxCashier.Campaign.Behaviour
  alias KantoxCashier.Product
  alias KantoxCashier.ShoppingCart.Cart

  @impl Behaviour
  def apply(%Cart{} = cart) do
    case Map.get(cart.products, Product.green_tea()) do
      nil -> cart
      {count, product} -> Cart.add_discount(cart, discount_amount(count, product))
    end
  end

  def discount_amount(count, product) do
    if count >= count_of_grean_tea() do
      Float.floor(count / 2) * product.price
    else
      nil
    end
  end

  @impl Behaviour
  def enabled?, do: config()[:enabled]

  defp count_of_grean_tea,
    do: config()[:count_of_grean_tea]

  defp config,
    do:
      Application.get_env(:kantox_cashier, :campaigns)
      |> Enum.find(fn {k, _v} -> k == __MODULE__ end)
      |> elem(1)
end
