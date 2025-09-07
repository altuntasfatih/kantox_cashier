defmodule KantoxCashier.ShoppingCart.UserCart do
  @moduledoc """
  GenServer managing individual user shopping cart state.

  ## Production Considerations

  # todo, think about adding persistence layer
  # option 1: use Ecto
  # pros: a very solid choice, save us
  # cons: External dependency,

  # option 2: use ETS
  # pros: easy peasy, for temproray processes crash would save us
  # cons: during deployment we lose the data because ets tables are tied to specific node,
  # cons: does not support cross node replication

  # option 3: use Distributed ETS(Mnesia)
  # pros: distributed,
  # cons: it is complex for simple shopping cart

  # option 4: State Transfer  during deployment
  # pros: i belive, it is too complex, what if we changed code and code



  """

  use GenServer
  alias KantoxCashier.ShoppingCart.CartProcessor

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, user_id, name: via_tuple(user_id))
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

  defp via_tuple(user_id) do
    {:via, Registry, {KantoxCashier.ShoppingCart.CartRegistry, {__MODULE__, user_id}}}
  end
end
