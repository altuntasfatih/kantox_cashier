defmodule KantoxCashier.Campaign.BulkPurchaseCoffee do
  @behaviour KantoxCashier.Campaign.Behaviour

  alias KantoxCashier.Campaign.Behaviour
  alias KantoxCashier.Product
  alias KantoxCashier.ShoppingCart.Cart

  @impl Behaviour
  def apply(%Cart{} = cart) do
    case Map.get(cart.basket, Product.coffee().code) do
      nil -> cart
      {count, _} -> Cart.add_campaign(cart, calculate_discount(count))
    end
  end

  @impl Behaviour
  def enabled?, do: config()[:enabled]

  defp name, do: config()[:name]

  defp calculate_discount(count) do
    if count >= count_of_coffee() do
      {name(), campaigns_amount() * count}
    end
  end

  defp count_of_coffee,
    do: config()[:count_of_coffee]

  defp campaigns_amount,
    do: config()[:campaigns_amount]

  defp config,
    do:
      Application.get_env(:kantox_cashier, :campaigns)
      |> Enum.find(fn {k, _v} -> k == __MODULE__ end)
      |> elem(1)
end
