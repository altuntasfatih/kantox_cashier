defmodule KantoxCashier.Cashier do
  alias KantoxCashier.ShoppingCart.CartRegistry

  def start(user_id) when is_integer(user_id) do
    case lookup_cart(user_id) do
      {:error, :cart_not_found} ->
        CartRegistry.create_shoping_cart(user_id)

      {:ok, pid} ->
        GenServer.call(pid, {:get_cart})
    end
  end

  def add_item(user_id, product_code) when is_integer(user_id) do
    with {:ok, pid} <- lookup_cart(user_id) do
      GenServer.call(pid, {:add_item, product_code})
    end
  end

  def remove_item(user_id, product_code) when is_integer(user_id) do
    with {:ok, pid} <- lookup_cart(user_id) do
      GenServer.call(pid, {:remove_item, product_code})
    end
  end

  def checkout(user_id) when is_integer(user_id) do
    with {:ok, pid} <- lookup_cart(user_id) do
      GenServer.call(pid, {:checkout})
    end
  end

  def get_cart(user_id) when is_integer(user_id) do
    with {:ok, pid} <- lookup_cart(user_id) do
      GenServer.call(pid, {:get_cart})
    end
  end

  defp lookup_cart(user_id) when is_integer(user_id) do
    case CartRegistry.where_is(user_id) do
      {:ok, pid} -> {:ok, pid}
      {:error, :process_is_not_alive} -> {:error, :cart_not_found}
    end
  end
end
