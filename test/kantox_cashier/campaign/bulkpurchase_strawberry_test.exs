defmodule KantoxCashier.Campaign.BulkPurchaseStrawberryTest do
  use KantoxCashier.DataCase
  alias KantoxCashier.Campaign.BulkPurchaseStrawberry

  describe "apply/1" do
    setup do
      cart = create_shopping_cart()
      {:ok, cart: cart}
    end

    test "should not apply discount when has no strawberry", %{cart: cart} do
      # when
      result = BulkPurchaseStrawberry.apply(cart)

      # then
      assert %Cart{discounts: []} = result
    end

    test "should not apply discount when strawberry count is below threshold", %{cart: cart} do
      # given - threshold is 3
      cart = add_strawberry_to_cart(cart, 2)

      # when
      result = BulkPurchaseStrawberry.apply(cart)

      # then
      assert %Cart{discounts: []} = result
    end

    test "should apply discount when strawberry count equals threshold", %{cart: cart} do
      # given - threshold is 3
      cart = add_strawberry_to_cart(cart, 3)

      # when
      result = BulkPurchaseStrawberry.apply(cart)

      # then
      expected_discount = 3 * 0.50
      expected_name = "Bulk Purchase Strawberry"

      assert %Cart{discounts: [{^expected_name, ^expected_discount}]} = result
    end

    test "should apply discount when coffee count exceeds threshold", %{cart: cart} do
      # given - threshold is 3
      cart = add_strawberry_to_cart(cart, 5)

      # when
      result = BulkPurchaseStrawberry.apply(cart)

      # then, discount amount per item is 0.50
      expected_discount = 5 * 0.50
      expected_name = "Bulk Purchase Strawberry"

      assert %Cart{discounts: [{^expected_name, ^expected_discount}]} = result
    end

    test "should only apply discount to coffee, ignoring other products", %{cart: cart} do
      # given - threshold is 3
      cart =
        cart
        |> add_strawberry_to_cart(4)
        |> add_coffee_to_cart(2)

      # when
      result = BulkPurchaseStrawberry.apply(cart)

      # then, discount amount per item is 0.50
      expected_discount = 4 * 0.50
      expected_name = "Bulk Purchase Strawberry"

      assert %Cart{discounts: [{^expected_name, ^expected_discount}]} = result
    end
  end
end
