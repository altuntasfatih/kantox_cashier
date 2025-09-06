defmodule KantoxCashierTest do
  #todo: later use ExUnit.Case, add termina all user_cart processes
  use ExUnit.Case

  alias KantoxCashier.Cashier
  alias KantoxCashier.Product
  alias KantoxCashier.ShoppingCart.Cart

  describe "start/1" do
    test "start successful" do
      assert %Cart{
               total: 0.0,
               products: %{},
               user_id: 1,
               discounts: [],
               amount: 0.0
             } == Cashier.start(1)

      assert %Cart{
               total: 0.0,
               products: %{},
               user_id: 12,
               discounts: [],
               amount: 0.0
             } == Cashier.start(12)
    end
  end

  describe "add_item/2" do
    test "add item to cart" do
      user_id = 99
      assert %Cart{user_id: ^user_id} = Cashier.start(user_id)

      assert %Cart{
               total: 11.23,
               products: %{CF1: {1, %Product{code: :CF1, price: 11.23}}},
               user_id: user_id,
               discounts: [],
               amount: 11.23
             } == Cashier.add_item(user_id, :CF1)

      assert %Cart{
               total: 16.23,
               products: %{
                 CF1: {1, %Product{code: :CF1, price: 11.23}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               user_id: user_id,
               discounts: [],
               amount: 16.23
             } == Cashier.add_item(user_id, :SR1)

      assert %Cart{
               total: 19.34,
               products: %{
                 CF1: {1, %Product{code: :CF1, price: 11.23}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}},
                 GR1: {1, %Product{code: :GR1, price: 3.11}}
               },
               user_id: user_id,
               discounts: [],
               amount: 19.34
             } == Cashier.add_item(user_id, :GR1)
    end

    test "should return cart not found" do
      assert {:error, :cart_not_found} == Cashier.add_item(22, :CF1)
    end

    # todo should not crash process
    test "should return invalid product code error" do
      user_id = 100
      assert %Cart{user_id: ^user_id} = Cashier.start(user_id)

      assert {:error, :invalid_product_code} == Cashier.add_item(user_id, :NON_EXISTING)
    end
  end
end
