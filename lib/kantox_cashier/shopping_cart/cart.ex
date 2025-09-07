defmodule KantoxCashier.ShoppingCart.Cart do
  defstruct [:user_id, :basket, :basket_amount, :campaigns, :campaigns_amount, :final_amount]

  alias KantoxCashier.Item
  alias KantoxCashier.ShoppingCart.Cart

  @type t :: %Cart{
          user_id: integer(),
          basket: map(),
          basket_amount: float(),
          campaigns: list(),
          campaigns_amount: float(),
          final_amount: float()
        }

  def new(user_id) when is_integer(user_id) do
    %Cart{
      user_id: user_id,
      basket: %{},
      basket_amount: 0.0,
      campaigns: [],
      campaigns_amount: 0.0,
      final_amount: 0.0
    }
  end

  def add_item(%Cart{basket: basket} = cart, %Item{} = item) do
    basket = Map.update(basket, item.code, {1, item}, fn {count, _} -> {count + 1, item} end)
    %{cart | basket: basket}
  end

  def remove_item(%Cart{basket: basket} = cart, item_code) do
    case Map.get(basket, item_code) do
      nil ->
        cart

      {1, _} ->
        %{cart | basket: Map.delete(basket, item_code)}

      {count, item} ->
        %{cart | basket: Map.put(basket, item_code, {count - 1, item})}
    end
  end

  def add_campaign(%Cart{} = cart, nil), do: cart

  def add_campaign(%Cart{campaigns: campaigns} = cart, campaign) do
    campaigns =
      [campaign | campaigns]
      |> Enum.sort_by(fn {_, campaign_amount} -> campaign_amount end, :desc)

    %{cart | campaigns: campaigns}
  end
end
