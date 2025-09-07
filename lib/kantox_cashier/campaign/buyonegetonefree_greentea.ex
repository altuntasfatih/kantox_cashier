defmodule KantoxCashier.Campaign.BuyOneGetOneFreeGreenTea do
  @behaviour KantoxCashier.Campaign.Behaviour

  alias KantoxCashier.Campaign.Behaviour
  alias KantoxCashier.Item
  alias KantoxCashier.ShoppingCart.Cart

  @impl Behaviour
  def apply(%Cart{} = cart) do
    case Map.get(cart.basket, Item.green_tea().code) do
      nil ->
        cart

      {green_tea_count, green_tea} ->
        Cart.add_campaign(cart, calculate_campaign(green_tea_count, green_tea.price))
    end
  end

  @impl Behaviour
  def enabled?, do: config()[:enabled]

  defp calculate_campaign(count, green_tea_price) do
    config = config()
    green_tea_count_threshold = config[:green_tea_count_threshold]

    if count >= green_tea_count_threshold do
      free_items = div(count, 2)
      {config[:name], green_tea_price * free_items}
    end
  end

  defp config,
    do:
      Application.get_env(:kantox_cashier, :campaigns)
      |> Enum.find(fn {k, _v} -> k == __MODULE__ end)
      |> elem(1)
end
