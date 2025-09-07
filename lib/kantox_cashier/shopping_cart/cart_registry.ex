defmodule KantoxCashier.ShoppingCart.CartRegistry do
  alias KantoxCashier.ShoppingCart.UserCart

  def create_shopping_cart(user_id) do
    DynamicSupervisor.start_child(
      KantoxCashier.ShoppingCart.CartDynamicSupervisor,
      {UserCart, user_id}
    )
  end

  @spec where_is(integer()) :: {:error, :cart_not_found} | {:ok, pid()}
  def where_is(user_id) when is_integer(user_id) do
    case Registry.lookup(__MODULE__, {UserCart, user_id}) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :cart_not_found}
    end
  end

  def child_spec(opts) do
    %{
      start: {__MODULE__, :start_link, [opts]}
    }
  end
end
