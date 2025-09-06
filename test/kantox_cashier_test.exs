defmodule KantoxCashierTest do
  use KantoxCashier.DataCase

  alias KantoxCashier

  describe "start/1" do
    test "start successful" do
      assert %Cart{
               total: 0.0,
               products: %{},
               user_id: 1,
               discounts: [],
               amount: 0.0
             } == KantoxCashier.start(1)

      assert %Cart{
               total: 0.0,
               products: %{},
               user_id: 12,
               discounts: [],
               amount: 0.0
             } == KantoxCashier.start(12)
    end

    test "should return same cart if exist" do
      user_id = 22
      assert %Cart{user_id: ^user_id, discounts: [], products: %{}} = KantoxCashier.start(user_id)
      assert %Cart{user_id: ^user_id, discounts: [], products: %{}} = KantoxCashier.start(user_id)
    end
  end

  describe "add_item/2" do
    setup do
      user_id = 99
      assert %Cart{user_id: ^user_id} = KantoxCashier.start(user_id)
      {:ok, %{user_id: user_id}}
    end

    test "should add items to cart", %{user_id: user_id} do
      assert %Cart{
               total: 11.23,
               products: %{CF1: {1, %Product{code: :CF1, price: 11.23}}},
               user_id: user_id,
               discounts: [],
               amount: 11.23
             } == KantoxCashier.add_item(user_id, :CF1)

      assert %Cart{
               total: 16.23,
               products: %{
                 CF1: {1, %Product{code: :CF1, price: 11.23}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               user_id: user_id,
               discounts: [],
               amount: 16.23
             } == KantoxCashier.add_item(user_id, :SR1)

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
             } == KantoxCashier.add_item(user_id, :GR1)
    end

    test "should return cart not found" do
      assert {:error, :cart_not_found} == KantoxCashier.add_item(22, :CF1)
    end

    test "should return invalid product code error", %{user_id: user_id} do
      assert {:error, :invalid_product_code} == KantoxCashier.add_item(user_id, :NON_EXISTING)
    end
  end

  describe "remove_item/2" do
    setup do
      user_id = 99
      assert %Cart{user_id: ^user_id} = KantoxCashier.start(user_id)
      %{user_id: user_id}
    end

    test "should remove items from cart", %{user_id: user_id} do
      # given
      assert %{} = KantoxCashier.add_item(user_id, :CF1)
      assert %{} = KantoxCashier.add_item(user_id, :CF1)
      assert %{} = KantoxCashier.add_item(user_id, :SR1)

      # when & then

      assert %Cart{
               products: %{CF1: {2, %Product{code: :CF1, price: 11.23}}}
             } = KantoxCashier.remove_item(user_id, :SR1)

      assert %Cart{
               products: %{CF1: {1, %Product{code: :CF1, price: 11.23}}}
             } = KantoxCashier.remove_item(user_id, :CF1)

      assert %Cart{amount: 0.0, discounts: [], products: %{}, total: 0.0, user_id: user_id} ==
               KantoxCashier.remove_item(user_id, :CF1)
    end

    test "should ignore not existing items", %{user_id: user_id} do
      assert %Cart{amount: 0.0, discounts: [], products: %{}, total: 0.0, user_id: user_id} ==
               KantoxCashier.remove_item(user_id, :CF1)
    end
  end

  describe "get_cart/1" do
    test "should return the cart for a user" do
      user_id = 12
      assert %{} = KantoxCashier.start(user_id)

      assert %Cart{user_id: ^user_id, products: %{}, discounts: []} =
               KantoxCashier.get_cart(user_id)
    end

    test "should return cart not found error" do
      assert {:error, :cart_not_found} == KantoxCashier.get_cart(22)
    end
  end
end
