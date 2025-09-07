defmodule KantoxCashier.Item do
  defstruct [:code, :price]

  def new(:CF1), do: coffee()
  def new(:GR1), do: green_tea()
  def new(:SR1), do: strawberry()
  def new(_), do: {:error, :invalid_item_code}

  def coffee, do: %__MODULE__{code: :CF1, price: price(:CF1)}
  def green_tea, do: %__MODULE__{code: :GR1, price: price(:GR1)}
  def strawberry, do: %__MODULE__{code: :SR1, price: price(:SR1)}

  def price(:CF1), do: config(:CF1)[:price]
  def price(:GR1), do: config(:GR1)[:price]
  def price(:SR1), do: config(:SR1)[:price]

  def code_to_string(:CF1), do: config(:CF1)[:name]
  def code_to_string(:GR1), do: config(:GR1)[:name]
  def code_to_string(:SR1), do: config(:SR1)[:name]

  defp config(code), do: Application.get_env(:kantox_cashier, :items)[code]
end
