defmodule KantoxCashier.ShoppingCart.CartProcessor do
  alias KantoxCashier.Product
  alias KantoxCashier.ShoppingCart.Cart

  def create_shopping_cart(user_id) when is_integer(user_id), do: Cart.new(user_id)

  def add_item(cart, %Product{} = product) do
    Cart.add_product(cart, product)
    |> checkout()
  end

  def remove_item(cart, product_code) do
    Cart.remove_product(cart, product_code)
    |> checkout()
  end

  def preview(cart) do
    cart = checkout(cart)

    basket_summary =
      Enum.map(cart.basket, fn {code, {count, %Product{price: price}}} ->
        %{
          name: Product.code_to_string(code),
          count: count,
          price: price,
          total: Float.round(count * price, 2)
        }
      end)

    %{
      user_id: cart.user_id,
      basket_summary: basket_summary,
      discount_summary:
        Enum.map(cart.discounts, fn {name, amount} ->
          %{discount_name: name, discount_amount: amount}
        end),
      basket_amount: cart.basket_amount,
      total_discounts: cart.total_discounts,
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

  defp calculate(%Cart{basket: basket, discounts: []} = cart) do
    basket_amount =
      basket
      |> Enum.map(fn {_code, {count, %Product{price: price}}} -> count * price end)
      |> Enum.sum()
      |> Float.round(2)

    %Cart{cart | basket_amount: basket_amount, final_amount: basket_amount}
  end

  defp calculate(%Cart{basket: basket, discounts: discounts} = cart) do
    basket_amount =
      basket
      |> Enum.map(fn {_code, {count, %Product{price: price}}} -> count * price end)
      |> Enum.sum()
      |> Float.round(2)

    total_discounts = Enum.sum_by(discounts, fn {_, discount} -> discount end) |> Float.round(2)
    final_amount = Float.round(basket_amount - total_discounts, 2)

    %Cart{
      cart
      | basket_amount: basket_amount,
        total_discounts: total_discounts,
        final_amount: final_amount
    }
  end

  defp apply_campaigns(cart) do
    load_campaigns()
    |> Enum.reduce(cart, fn campaign, cart -> campaign.apply(cart) end)
  end

  defp reset_calculations(cart) do
    %Cart{cart | discounts: [], final_amount: 0.0, basket_amount: 0.0, total_discounts: 0.0}
  end

  defp load_campaigns do
    Application.get_env(:kantox_cashier, :campaigns, [])
    |> Enum.map(fn {module_name, _opts} -> module_name end)
    |> Enum.filter(fn c -> c.enabled?() end)
  end
end
