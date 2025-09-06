defmodule KantoxCashier.Product do
  defstruct [:code, :price]

  def new(:CF1), do: coffee()
  def new(:GR1), do: green_tea()
  def new(:SR1), do: strawberry()
  def new(_), do: {:error, :invalid_product_code}

  def coffee, do: %__MODULE__{code: :CF1, price: price(:CF1)}
  def green_tea, do: %__MODULE__{code: :GR1, price: price(:GR1)}
  def strawberry, do: %__MODULE__{code: :SR1, price: price(:SR1)}

  def price(:CF1), do: Application.get_env(:kantox_cashier, :products)[:CF1]
  def price(:GR1), do: Application.get_env(:kantox_cashier, :products)[:GR1]
  def price(:SR1), do: Application.get_env(:kantox_cashier, :products)[:SR1]

  def code_to_string(:CF1), do: "Coffee"
  def code_to_string(:GR1), do: "Green Tea"
  def code_to_string(:SR1), do: "Strawberry"
end
