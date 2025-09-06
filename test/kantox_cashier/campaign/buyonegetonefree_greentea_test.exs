defmodule KantoxCashier.Campaign.BuyOneGetOneFreeGreenteaTest do
  use KantoxCashier.DataCase
  alias KantoxCashier.Campaign.BuyOneGetOneFreeGreentea

  describe "apply/1" do
    setup do
      cart = create_shopping_cart()
      {:ok, cart: cart}
    end

    test "should not apply discount when has no greentea", %{cart: cart} do
      # when
      result = BuyOneGetOneFreeGreentea.apply(cart)

      # then
      assert %Cart{discounts: []} = result
    end

    test "should not apply discount when there is one greentea", %{cart: cart} do
      # given
      cart = add_greentea_to_cart(cart, 1)

      # when
      result = BuyOneGetOneFreeGreentea.apply(cart)

      # then
      assert %Cart{discounts: []} = result
    end

    test "should apply discount when there is two greentea", %{cart: cart} do
      # given - buy one get one free
      cart = add_greentea_to_cart(cart, 2)

      # when
      result = BuyOneGetOneFreeGreentea.apply(cart)

      # then, one greentea is free
      expected_discount = 1 * 3.11
      expected_name = "Buy One Get One Free Green Tea"

      assert %Cart{discounts: [{^expected_name, ^expected_discount}]} = result
    end

    test "should apply discount when there is more than two greentea", %{cart: cart} do
      # given
      cart = add_greentea_to_cart(cart, 5)

      # when
      result = BuyOneGetOneFreeGreentea.apply(cart)

      # then, two greentea is free
      expected_discount = 2 * 3.11
      expected_name = "Buy One Get One Free Green Tea"

      assert %Cart{discounts: [{^expected_name, ^expected_discount}]} = result
    end

    test "should only apply discount to greentea, ignoring other basket", %{cart: cart} do
      # given
      cart =
        cart
        |> add_greentea_to_cart(9)
        |> add_strawberry_to_cart(2)

      # when
      result = BuyOneGetOneFreeGreentea.apply(cart)

      # then, four greentea is free
      expected_discount = 4 * 3.11
      expected_name = "Buy One Get One Free Green Tea"

      assert %Cart{discounts: [{^expected_name, ^expected_discount}]} = result
    end
  end
end
