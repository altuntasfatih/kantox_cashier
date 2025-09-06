defmodule KantoxCashier.ShoppingCart.CartRegistry do
  alias KantoxCashier.ShoppingCart.UserCart

  def create_shopping_cart(user_id) do
    DynamicSupervisor.start_child(
      KantoxCashier.ShoppingCart.CartSupervisor,
      {UserCart, user_id}
    )
  end

  @spec where_is(integer()) :: {:error, :process_is_not_alive} | {:ok, pid()}
  def where_is(user_id) when is_integer(user_id) do
    case Registry.lookup(__MODULE__, {UserCart, user_id}) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :process_is_not_alive}
    end
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      restart: :transient
    }
  end
end
