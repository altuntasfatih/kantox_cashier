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

  def summarize_cart(cart) do
    cart = checkout(cart)

    product_summary =
      Enum.map(cart.products, fn {code, {count, %Product{price: price}}} ->
        %{
          product: Product.code_to_string(code),
          count: count,
          price: price,
          total: Float.round(count * price, 2)
        }
      end)

    discount_summary = %{
      total_discounts: Enum.sum(cart.discounts),
      discounts: cart.discounts
    }

    %{
      user_id: cart.user_id,
      products: product_summary,
      shopping_cart_amount: cart.amount,
      discounts: discount_summary.discounts,
      total_discounts: discount_summary.total_discounts,
      final_amount: cart.total
    }
  end

  def checkout(cart) do
    cart
    |> apply_campaigns()
    |> calculate()
  end

  defp calculate(%Cart{products: products} = cart) when products == %{}, do: cart

  defp calculate(%Cart{products: products, discounts: []} = cart) do
    total =
      products
      |> Enum.map(fn {_code, {count, %Product{price: price}}} -> count * price end)
      |> Enum.sum()

    %Cart{cart | amount: Float.round(total, 2), total: Float.round(total, 2)}
  end

  defp calculate(%Cart{products: products, discounts: discounts} = cart) do
    amount =
      products
      |> Enum.map(fn {_code, {count, %Product{price: price}}} -> count * price end)
      |> Enum.sum()

    total = amount - Enum.sum_by(discounts, fn {_name, amount} -> amount end)
    %Cart{cart | amount: Float.round(amount, 2), total: Float.round(total, 2)}
  end

  defp apply_campaigns(cart) do
    cart = %Cart{cart | discounts: [], total: 0.0, amount: 0.0}

    load_campaigns()
    |> Enum.reduce(cart, fn campaign, cart -> campaign.apply(cart) end)
  end

  defp load_campaigns do
    Application.get_env(:kantox_cashier, :campaigns, [])
    |> Enum.map(fn {module_name, _opts} -> module_name end)
    |> Enum.filter(fn c -> c.enabled?() end)
  end
end
