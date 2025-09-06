defmodule KantoxCashier.Campaign.BulkPurchaseCoffeeTest do
  use KantoxCashier.DataCase

  alias KantoxCashier.Campaign.BulkPurchaseCoffee

  test "it should not give discount" do
    cart = create_shoping_cart() |> add_coffee_to_cart()

    assert %Cart{
             discounts: []
           } = BulkPurchaseCoffee.apply(cart)

    cart = cart |> add_strawberry_to_cart()
    assert %Cart{discounts: []} = BulkPurchaseCoffee.apply(cart)
  end

  test "it should give discount when there is more than 2 coffee" do
    cart =
      create_shoping_cart() |> add_coffee_to_cart(3)

    discount_amount = 3 * 3.75
    name = BulkPurchaseCoffee.name()

    assert %Cart{discounts: [{^name, ^discount_amount}]} = BulkPurchaseCoffee.apply(cart)
  end
end
