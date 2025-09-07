defmodule KantoxCashier.Application do
  use Application

  @spec start(any(), any()) :: {:error, any()} | {:ok, pid()}
  def start(_type, _args) do
    children = [
      {KantoxCashier.ShoppingCart.CartRegistry, []},
      # no need module
      {DynamicSupervisor, name: KantoxCashier.ShoppingCart.CartDynamicSupervisor}
    ]

    opts = [strategy: :one_for_one, name: KantoxCashier.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
