defmodule KantoxCashier.Campaign.BulkPurchaseCoffeeTest do
  use KantoxCashier.DataCase

  alias KantoxCashier.Campaign.BulkPurchaseCoffee

  describe "apply/1" do
    setup do
      cart = create_shopping_cart()
      {:ok, cart: cart}
    end

    test "should not apply discount when has no coffee", %{cart: cart} do
      # when
      result = BulkPurchaseCoffee.apply(cart)

      # then
      assert %Cart{discounts: []} = result
    end

    test "should not apply discount when coffee count is below threshold", %{cart: cart} do
      # given - threshold is 3
      cart = add_coffee_to_cart(cart, 2)

      # when
      result = BulkPurchaseCoffee.apply(cart)

      # then
      assert %Cart{discounts: []} = result
    end

    test "should apply discount when coffee count equals threshold", %{cart: cart} do
      # given - threshold is 3
      cart = add_coffee_to_cart(cart, 3)

      # when
      result = BulkPurchaseCoffee.apply(cart)

      # then
      expected_discount = 3 * 3.75
      expected_name = "Bulk Purchase Coffee"

      assert %Cart{discounts: [{^expected_name, ^expected_discount}]} = result
    end

    test "should apply discount when coffee count exceeds threshold", %{cart: cart} do
      # given - threshold is 3
      cart = add_coffee_to_cart(cart, 5)

      # when
      result = BulkPurchaseCoffee.apply(cart)

      # then
      expected_discount = 5 * 3.75
      expected_name = "Bulk Purchase Coffee"

      assert %Cart{discounts: [{^expected_name, ^expected_discount}]} = result
    end

    test "should only apply discount to coffee, ignoring other products", %{cart: cart} do
      # given - threshold is 3
      cart =
        cart
        |> add_coffee_to_cart(4)
        |> add_strawberry_to_cart(2)

      # when
      result = BulkPurchaseCoffee.apply(cart)

      # then
      expected_discount = 4 * 3.75
      expected_name = "Bulk Purchase Coffee"

      assert %Cart{discounts: [{^expected_name, ^expected_discount}]} = result
    end
  end
end
