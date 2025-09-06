defmodule KantoxCashier.ShoppingCart.Cart do
  defstruct [:user_id, :products, :amount, :discounts, :total]

  alias KantoxCashier.Product

  @type t :: %__MODULE__{
          user_id: integer(),
          products: list(),
          amount: float(),
          discounts: list(),
          total: float()
        }

  def new(user_id) when is_integer(user_id) do
    %__MODULE__{
      user_id: user_id,
      products: %{},
      amount: 0.00,
      discounts: [],
      total: 0.00
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
    {count, product} = Map.fetch!(products, product_code)

    if count > 1 do
      %{cart | products: Map.put(products, product_code, {count - 1, product})}
    else
      %{cart | products: Map.delete(products, product_code)}
    end
  end

  def add_discount(%__MODULE__{} = cart, nil), do: cart

  def add_discount(%__MODULE__{discounts: discounts} = cart, discount),
    do: %{cart | discounts: [discount | discounts] |> Enum.sort()}
end
