defmodule KantoxCashier.Campaign.BuyOneGetOneFreeGreentea do
  @behaviour KantoxCashier.Campaign.Behaviour

  alias KantoxCashier.Campaign.Behaviour
  alias KantoxCashier.Product
  alias KantoxCashier.ShoppingCart.Cart

  @impl Behaviour
  def apply(%Cart{} = cart) do
    case Map.get(cart.products, Product.green_tea().code) do
      nil -> cart
      {count, green_tea} -> Cart.add_discount(cart, calculate_discount(count, green_tea))
    end
  end

  @impl Behaviour
  def enabled?, do: config()[:enabled]

  defp name, do: config()[:name]

  defp calculate_discount(count, green_tea) do
    if count >= count_of_green_tea() do
      free_items = div(count, 2)
      {name(), free_items * green_tea.price}
    end
  end

  defp count_of_green_tea,
    do: config()[:count_of_green_tea]

  defp config,
    do:
      Application.get_env(:kantox_cashier, :campaigns)
      |> Enum.find(fn {k, _v} -> k == __MODULE__ end)
      |> elem(1)
end
