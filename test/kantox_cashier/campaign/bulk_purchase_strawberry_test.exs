defmodule KantoxCashier.Campaign.BulkPurchaseStrawberryTest do
  use KantoxCashier.DataCase
  alias KantoxCashier.Campaign.BulkPurchaseStrawberry

  test "it should not give discount" do
    cart = create_shoping_cart() |> add_strawberry_to_cart()

    assert %Cart{
             discounts: []
           } = BulkPurchaseStrawberry.apply(cart)

    cart = cart |> add_greentea_to_cart()
    assert %Cart{discounts: []} = BulkPurchaseStrawberry.apply(cart)
  end

  test "it should give discount when there is more than 2 strawberry" do
    cart = create_shoping_cart() |> add_strawberry_to_cart(4)

    discount_amount = 4 * 0.50

    assert %Cart{discounts: [^discount_amount]} = BulkPurchaseStrawberry.apply(cart)
  end
end
