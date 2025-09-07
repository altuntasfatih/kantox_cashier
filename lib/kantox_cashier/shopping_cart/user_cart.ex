defmodule KantoxCashier.ShoppingCart.UserCart do
  @moduledoc """
  GenServer managing individual user cart state.

  For production deployment, consider adding persistence:
  - **Database (Ecto)**: Best for data durability across deployments
  - **Mnesia**: Distributed but complex for simple carts

  Current in-memory approach is suitable for:
  - Development/testing
  - Stateless applications
  - When cart data loss is acceptable

  Current implementation focuses on OTP patterns and clean architecture
  """

  use GenServer
  alias KantoxCashier.ShoppingCart.CartProcessor
  alias KantoxCashier.ShoppingCart.CartRegistry

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, user_id, name: CartRegistry.via_tuple({__MODULE__, user_id}))
  end

  def init(user_id) do
    {:ok, CartProcessor.create_shopping_cart(user_id)}
  end

  def handle_call({:add_item, item}, _from, cart) do
    updated_cart = CartProcessor.add_item(cart, item)
    {:reply, updated_cart, updated_cart}
  end

  def handle_call({:remove_item, item_code}, _from, cart) do
    updated_cart = CartProcessor.remove_item(cart, item_code)
    {:reply, updated_cart, updated_cart}
  end

  def handle_call({:get_cart}, _, cart) do
    {:reply, cart, cart}
  end

  def handle_call({:preview}, _from, cart) do
    {:reply, CartProcessor.preview(cart), cart}
  end
end
