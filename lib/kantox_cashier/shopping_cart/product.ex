defmodule KantoxCashier.Product do
  defstruct [:code, :price]

  def new(:CF1), do: %__MODULE__{code: coffee(), price: price(coffee())}
  def new(:GR1), do: %__MODULE__{code: green_tea(), price: price(green_tea())}
  def new(:SR1), do: %__MODULE__{code: strawbery(), price: price(strawbery())}
  def new(_), do: {:error, :invalid_product_code}

  # todo it might return product struct, not atom lets see
  def coffee, do: :CF1
  def green_tea, do: :GR1
  def strawbery, do: :SR1

  def price(:CF1), do: Application.get_env(:kantox_cashier, :products)[:CF1]
  def price(:GR1), do: Application.get_env(:kantox_cashier, :products)[:GR1]
  def price(:SR1), do: Application.get_env(:kantox_cashier, :products)[:SR1]

  def code_to_string(:CF1), do: "Coffee"
  def code_to_string(:GR1), do: "Green Tea"
  def code_to_string(:SR1), do: "Strawberry"
end
