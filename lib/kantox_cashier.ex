defmodule KantoxCashier do
  alias KantoxCashier.Item
  alias KantoxCashier.ShoppingCart.CartRegistry

  def start(user_id) when is_integer(user_id) do
    case lookup_cart(user_id) do
      {:error, :cart_not_found} ->
        create_shopping_cart(user_id)

      {:ok, pid} ->
        GenServer.call(pid, {:get_cart})
    end
  end

  def add_item(user_id, item_code) when is_integer(user_id) do
    with %Item{} = item <- Item.new(item_code),
         {:ok, pid} <- lookup_cart(user_id) do
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
    with {:ok, pid} <- lookup_cart(user_id) do
      GenServer.call(pid, {:get_cart})
    end
  end

  defp create_shopping_cart(user_id) when is_integer(user_id) do
    with {:ok, pid} <- CartRegistry.create_shopping_cart(user_id) do
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
