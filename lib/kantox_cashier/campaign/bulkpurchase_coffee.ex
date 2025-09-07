defmodule KantoxCashier.Campaign.BulkPurchaseCoffee do
  @behaviour KantoxCashier.Campaign.Behaviour

  alias KantoxCashier.Campaign.Behaviour
  alias KantoxCashier.Item
  alias KantoxCashier.ShoppingCart.Cart

  @impl Behaviour
  def apply(%Cart{} = cart) do
    case Map.get(cart.basket, Item.coffee().code) do
      nil -> cart
      {coffee_count, _} -> Cart.add_campaign(cart, calculate_campaign(coffee_count))
    end
  end

  @impl Behaviour
  def enabled?, do: config()[:enabled]

  defp calculate_campaign(coffee_count) do
    config = config()
    coffee_count_threshold = config[:coffee_count_threshold]
    campaigns_amount = config[:campaigns_amount]

    if coffee_count >= coffee_count_threshold do
      {config[:name], campaigns_amount * coffee_count}
    end
  end

  defp config,
    do:
      Application.get_env(:kantox_cashier, :campaigns)
      |> Enum.find(fn {k, _v} -> k == __MODULE__ end)
      |> elem(1)
end
