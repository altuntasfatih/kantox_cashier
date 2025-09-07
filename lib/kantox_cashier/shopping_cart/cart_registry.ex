defmodule KantoxCashier.ShoppingCart.CartRegistry do
  alias KantoxCashier.ShoppingCart.UserCart

  def start_link do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  @spec create_shopping_cart(integer()) :: {:ok, pid()} | {:error, any()}
  def create_shopping_cart(user_id) do
    DynamicSupervisor.start_child(
      KantoxCashier.ShoppingCart.CartDynamicSupervisor,
      %{
        id: UserCart,
        start: {UserCart, :start_link, [user_id]},
        restart: :transient
      }
    )
  end

  @spec where_is(integer()) :: {:error, :cart_not_found} | {:ok, pid()}
  def where_is(user_id) when is_integer(user_id) do
    case Registry.lookup(__MODULE__, {UserCart, user_id}) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :cart_not_found}
    end
  end

  def via_tuple(term) do
    {:via, Registry, {__MODULE__, term}}
  end

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor,
      restart: :permanent,
      shutdown: :infinity
    }
  end
end
