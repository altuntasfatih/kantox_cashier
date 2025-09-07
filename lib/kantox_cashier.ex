defmodule KantoxCashier do
  alias KantoxCashier.Item
  alias KantoxCashier.ShoppingCart.CartRegistry

  def add_item(user_id, item_code) when is_integer(user_id) do
    with %Item{} = item <- Item.new(item_code),
         {:ok, pid} <- get_cart_pid_or_create(user_id) do
      GenServer.call(pid, {:add_item, item})
    end
  end

  def remove_item(user_id, item_code) when is_integer(user_id) do
    with {:ok, pid} <- lookup_cart(user_id) do
      GenServer.call(pid, {:remove_item, item_code})
    end
  end

  def preview(user_id) when is_integer(user_id) do
    with {:ok, pid} <- lookup_cart(user_id) do
      GenServer.call(pid, {:preview})
    end
  end

  def get_cart(user_id) when is_integer(user_id) do
    with {:ok, pid} <- get_cart_pid_or_create(user_id) do
      GenServer.call(pid, {:get_cart})
    end
  end

  defp lookup_cart(user_id) when is_integer(user_id) do
    with {:ok, pid} <- CartRegistry.where_is(user_id) do
      {:ok, pid}
    end
  end

  defp get_cart_pid_or_create(user_id) when is_integer(user_id) do
    with {:error, :cart_not_found} <- lookup_cart(user_id),
         {:ok, pid} <- CartRegistry.create_shopping_cart(user_id) do
      {:ok, pid}
    end
  end
end
