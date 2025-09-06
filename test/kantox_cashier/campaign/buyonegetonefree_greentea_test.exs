defmodule KantoxCashier.Campaign.BuyOneGetOneFreeGreenteaTest do
  use KantoxCashier.DataCase
  alias KantoxCashier.Campaign.BuyOneGetOneFreeGreentea

  test "it should not give discount" do
    cart = create_shoping_cart() |> add_greentea_to_cart()

    assert %Cart{
             discounts: []
           } = BuyOneGetOneFreeGreentea.apply(cart)

    cart = cart |> add_strawberry_to_cart()
    assert %Cart{discounts: []} = BuyOneGetOneFreeGreentea.apply(cart)
  end

  test "it should give discount when there is more than 3 coffee" do
    cart =
      create_shoping_cart()
      |> add_greentea_to_cart(3)

    discount_amount = 1 * 3.11
    name = BuyOneGetOneFreeGreentea.name()

    assert %Cart{discounts: [{^name, ^discount_amount}]} = BuyOneGetOneFreeGreentea.apply(cart)
  end
end
