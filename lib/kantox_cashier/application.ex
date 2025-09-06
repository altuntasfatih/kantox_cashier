defmodule KantoxCashier.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: KantoxCashier.ShopingCart.CartRegistry},
      {DynamicSupervisor, name: KantoxCashier.ShopingCart.CartSupervisor, strategy: :one_for_one}
    ]

    opts = [strategy: :one_for_one, name: KantoxCashier.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
