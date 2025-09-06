defmodule KantoxCashier.ShoppingCart.Cart do
  defstruct [:user_id, :basket, :basket_amount, :discounts, :total_discounts, :final_amount]

  alias KantoxCashier.Product

  @type t :: %__MODULE__{
          user_id: integer(),
          basket: map(),
          basket_amount: float(),
          discounts: list(),
          total_discounts: float(),
          final_amount: float()
        }

  def new(user_id) when is_integer(user_id) do
    %__MODULE__{
      user_id: user_id,
      basket: %{},
      basket_amount: 0.00,
      discounts: [],
      total_discounts: 0.00,
      final_amount: 0.00
    }
  end

  def add_product(%__MODULE__{basket: basket} = cart, %Product{} = p) do
    case Map.get(basket, p.code) do
      nil -> %__MODULE__{cart | basket: Map.put(basket, p.code, {1, p})}
      {count, _} -> %__MODULE__{cart | basket: Map.put(basket, p.code, {count + 1, p})}
    end
  end

  def remove_product(%__MODULE__{basket: basket} = cart, product_code) do
    case Map.get(basket, product_code) do
      nil ->
        cart

      {1, _} ->
        %__MODULE__{cart | basket: Map.delete(basket, product_code)}

      {count, product} ->
        %__MODULE__{cart | basket: Map.put(basket, product_code, {count - 1, product})}
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
