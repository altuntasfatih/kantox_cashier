defmodule KantoxCashier.Campaign.Behaviour do
  @callback apply(KantoxCashier.ShoppingCart.Cart.t()) :: KantoxCashier.ShoppingCart.Cart.t()
  @callback enabled?() :: boolean()
end
