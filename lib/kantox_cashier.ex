defmodule KantoxCashier do
  @moduledoc """
  Main API for the Kantox Cashier shopping cart system.

  This module provides a high-level interface for managing shopping carts,
  including adding/removing items and previewing cart contents.

  ## Examples

      # Add items to a user's cart, returns updated cart, if not exists creates a new cart
      KantoxCashier.add_item(123, :CF1)
      KantoxCashier.add_item(123, :GR1)

      # Preview cart user friendly response, kind of summary
      KantoxCashier.preview(123)

      # Remove items, returns updated cart, if not exists returns error
      KantoxCashier.remove_item(123, :CF1)
  """

  alias KantoxCashier.Item
  alias KantoxCashier.ShoppingCart.CartRegistry
  alias KantoxCashier.ShoppingCart.Cart

  @spec add_item(integer(), atom()) :: Cart.t() | {:error, :invalid_item_code}
  def add_item(user_id, item_code) when is_integer(user_id) do
    with %Item{} = item <- Item.new(item_code),
         {:ok, pid} <- get_cart_pid_or_create(user_id) do
      GenServer.call(pid, {:add_item, item})
    end
  end

  @spec remove_item(integer(), atom()) ::
          Cart.t() | {:error, :invalid_item_code | :cart_not_found}
  def remove_item(user_id, item_code) when is_integer(user_id) do
    with {:ok, pid} <- lookup_cart(user_id) do
      GenServer.call(pid, {:remove_item, item_code})
    end
  end

  @spec preview(integer()) :: map() | {:error, :cart_not_found}
  def preview(user_id) when is_integer(user_id) do
    with {:ok, pid} <- lookup_cart(user_id) do
      GenServer.call(pid, {:preview})
    end
  end

  @spec get_cart(integer()) :: Cart.t()
  def get_cart(user_id) when is_integer(user_id) do
    with {:ok, pid} <- get_cart_pid_or_create(user_id) do
      GenServer.call(pid, {:get_cart})
    end
  end

  defp lookup_cart(user_id) when is_integer(user_id), do: CartRegistry.where_is(user_id)

  defp get_cart_pid_or_create(user_id) when is_integer(user_id) do
    with {:error, :cart_not_found} <- lookup_cart(user_id) do
      CartRegistry.create_shopping_cart(user_id)
    end
  end
end
