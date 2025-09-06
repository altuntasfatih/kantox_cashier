defmodule KantoxCashier.ShoppingCart.Cart do
  defstruct [:user_id, :products, :discounts, :amount, :total_discounts, :final_amount]

  alias KantoxCashier.Product

  @type t :: %__MODULE__{
          user_id: integer(),
          products: map(),
          discounts: list(),
          amount: float(),
          total_discounts: float(),
          final_amount: float()
        }

  def new(user_id) when is_integer(user_id) do
    %__MODULE__{
      user_id: user_id,
      products: %{},
      discounts: [],
      amount: 0.00,
      total_discounts: 0.00,
      final_amount: 0.00
    }
  end

  def add_product(%__MODULE__{products: products} = cart, %Product{} = p) do
    %{
      cart
      | products: Map.update(products, p.code, {1, p}, fn {count, p} -> {count + 1, p} end)
    }
  end

  def remove_product(%__MODULE__{products: products} = cart, product_code)
      when is_atom(product_code) do
    case Map.has_key?(products, product_code) do
      true -> do_remove_product(cart, product_code)
      false -> cart
    end
  end

  defp do_remove_product(%__MODULE__{products: products} = cart, product_code) do
    {count, product} = Map.fetch!(products, product_code)

    if count > 1 do
      %{cart | products: Map.put(products, product_code, {count - 1, product})}
    else
      %{cart | products: Map.delete(products, product_code)}
    end
  end

  def add_discount(%__MODULE__{} = cart, nil), do: cart

  def add_discount(%__MODULE__{discounts: discounts} = cart, discount) do
    discounts =
      [discount | discounts]
      |> Enum.sort_by(fn {_, discount_amount} -> discount_amount end, :desc)

    %{cart | discounts: discounts}
  end
end
