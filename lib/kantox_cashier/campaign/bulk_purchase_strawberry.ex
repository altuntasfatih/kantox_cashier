defmodule KantoxCashier.Campaign.BulkPurchaseStrawberry do
  @behaviour KantoxCashier.Campaign.Behaviour

  alias KantoxCashier.Campaign.Behaviour
  alias KantoxCashier.Product
  alias KantoxCashier.ShoppingCart.Cart

  @impl Behaviour
  def apply(%Cart{} = cart) do
    case Map.get(cart.products, Product.strawbery()) do
      nil -> cart
      {count, _} -> Cart.add_discount(cart, discount_amount(count))
    end
  end

  def discount_amount(count) do
    if count >= count_of_strawberry() do
      discount_amount() * count
    else
      nil
    end
  end

  @impl Behaviour
  def enabled?,
    do: config()[:enabled]

  defp count_of_strawberry,
    do: config()[:count_of_strawberry]

  defp discount_amount,
    do: config()[:discount_amount]

  defp config,
    do:
      Application.get_env(:kantox_cashier, :campaigns)
      |> Enum.find(fn {k, _v} -> k == __MODULE__ end)
      |> elem(1)
end
