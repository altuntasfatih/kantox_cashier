defmodule KantoxCashier.ShoppingCart.UserCart do
  use GenServer
  alias KantoxCashier.ShoppingCart.CartProcessor

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, user_id, name: via_tuple(user_id))
  end

  def init(user_id) do
    {:ok, CartProcessor.create_shopping_cart(user_id)}
  end

  def handle_call({:add_item, product_code}, _from, cart) do
    updated_cart = CartProcessor.add_item(cart, product_code)
    {:reply, updated_cart, updated_cart}
  end

  def handle_call({:remove_item, product_code}, _from, cart) do
    updated_cart = CartProcessor.remove_item(cart, product_code)
    {:reply, updated_cart, updated_cart}
  end

  def handle_call({:get_cart}, _, state) do
    {:reply, state, state}
  end

  def handle_call({:checkout}, _from, cart) do
    {:reply, CartProcessor.checkout(cart), cart}
  end

  defp via_tuple(user_id) do
    {:via, Registry, {KantoxCashier.ShoppingCart.CartRegistry, {__MODULE__, user_id}}}
  end
end
