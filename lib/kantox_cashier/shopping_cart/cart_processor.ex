defmodule KantoxCashier.ShoppingCart.CartProcessor do
  alias KantoxCashier.Item
  alias KantoxCashier.ShoppingCart.Cart

  def create_shopping_cart(user_id) when is_integer(user_id), do: Cart.new(user_id)

  def add_item(cart, %Item{} = item) do
    Cart.add_item(cart, item)
    |> checkout()
  end

  def remove_item(cart, item_code) do
    Cart.remove_item(cart, item_code)
    |> checkout()
  end

  def preview(cart) do
    cart = checkout(cart)

    basket_summary =
      Enum.map(cart.basket, fn {code, {count, %Item{price: price}}} ->
        %{
          name: Item.code_to_string(code),
          count: count,
          price: price,
          total: Float.round(count * price, 2)
        }
      end)

    %{
      user_id: cart.user_id,
      basket_summary: basket_summary,
      campaigns_summary:
        Enum.map(cart.campaigns, fn {name, amount} ->
          %{campaign_name: name, campaigns_amount: amount}
        end),
      basket_amount: cart.basket_amount,
      campaigns_amount: cart.campaigns_amount,
      final_amount: cart.final_amount
    }
  end

  def checkout(cart) do
    cart
    |> reset_calculations()
    |> apply_campaigns()
    |> calculate()
  end

  defp calculate(%Cart{basket: basket} = cart) when basket == %{}, do: cart

  defp calculate(%Cart{basket: basket, campaigns: []} = cart) do
    basket_amount =
      basket
      |> Enum.map(fn {_code, {count, %Item{price: price}}} -> count * price end)
      |> Enum.sum()
      |> Float.round(2)

    %Cart{cart | basket_amount: basket_amount, final_amount: basket_amount}
  end

  defp calculate(%Cart{basket: basket, campaigns: campaigns} = cart) do
    basket_amount =
      basket
      |> Enum.map(fn {_code, {count, %Item{price: price}}} -> count * price end)
      |> Enum.sum()
      |> Float.round(2)

    campaigns_amount =
      Enum.sum_by(campaigns, fn {_, campaign_amount} -> campaign_amount end) |> Float.round(2)

    final_amount = Float.round(basket_amount - campaigns_amount, 2)

    %Cart{
      cart
      | basket_amount: basket_amount,
        campaigns_amount: campaigns_amount,
        final_amount: final_amount
    }
  end

  defp apply_campaigns(cart) do
    load_campaigns()
    |> Enum.reduce(cart, fn campaign, cart -> campaign.apply(cart) end)
  end

  defp reset_calculations(cart) do
    %Cart{cart | campaigns: [], final_amount: 0.0, basket_amount: 0.0, campaigns_amount: 0.0}
  end

  defp load_campaigns do
    Application.get_env(:kantox_cashier, :campaigns, [])
    |> Enum.map(fn {module_name, _opts} -> module_name end)
    |> Enum.filter(fn c -> c.enabled?() end)
  end
end
