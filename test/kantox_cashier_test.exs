defmodule KantoxCashierTest do
  use KantoxCashier.DataCase

  alias KantoxCashier

  describe "start/1" do
    test "start successful" do
      assert %Cart{
               user_id: 1,
               products: %{},
               discounts: [],
               amount: 0.0,
               total_discounts: 0.0,
               final_amount: 0.0
             } == KantoxCashier.start(1)

      assert %Cart{
               user_id: 12,
               products: %{},
               discounts: [],
               amount: 0.0,
               total_discounts: 0.0,
               final_amount: 0.0
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
               user_id: user_id,
               products: %{CF1: {1, Product.coffee()}},
               amount: Product.coffee().price,
               discounts: [],
               total_discounts: 0.0,
               final_amount: Product.coffee().price
             } == KantoxCashier.add_item(user_id, :CF1)

      assert %Cart{
               user_id: user_id,
               discounts: [],
               products: %{
                 CF1: {1, Product.coffee()},
                 SR1: {1, Product.strawberry()}
               },
               amount: 16.23,
               total_discounts: 0.0,
               final_amount: 16.23
             } == KantoxCashier.add_item(user_id, :SR1)

      assert %Cart{
               user_id: user_id,
               discounts: [],
               products: %{
                 CF1: {1, Product.coffee()},
                 GR1: {1, Product.green_tea()},
                 SR1: {1, Product.strawberry()}
               },
               amount: 19.34,
               total_discounts: 0.0,
               final_amount: 19.34
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
               products: %{CF1: {2, %Product{code: :CF1}}}
             } = KantoxCashier.remove_item(user_id, :SR1)

      assert %Cart{
               products: %{CF1: {1, %Product{code: :CF1}}}
             } = KantoxCashier.remove_item(user_id, :CF1)

      assert %Cart{
               user_id: user_id,
               discounts: [],
               products: %{},
               amount: 0.0,
               total_discounts: 0.0,
               final_amount: 0.0
             } ==
               KantoxCashier.remove_item(user_id, :CF1)
    end

    test "should ignore not existing items", %{user_id: user_id} do
      assert %Cart{
               user_id: user_id,
               discounts: [],
               products: %{},
               amount: 0.0,
               total_discounts: 0.0,
               final_amount: 0.0
             } ==
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

  describe "preview/1" do
    test "should return the cart preview for a user" do
      # given
      user_id = 33
      KantoxCashier.start(33)
      assert %{} = KantoxCashier.add_item(user_id, :CF1)
      assert %{} = KantoxCashier.add_item(user_id, :CF1)
      assert %{} = KantoxCashier.add_item(user_id, :SR1)
      assert %{} = KantoxCashier.add_item(user_id, :SR1)
      assert %{} = KantoxCashier.add_item(user_id, :SR1)
      assert %{} = KantoxCashier.add_item(user_id, :GR1)
      assert %{} = KantoxCashier.add_item(user_id, :GR1)

      # when & then
      assert %{
               user_id: ^user_id,
               products: [
                 %{product: "Coffee", count: 2, price: 11.23, total: 22.46},
                 %{product: "Strawberry", count: 3, price: 5.0, total: 15.0},
                 %{product: "Green Tea", count: 2, price: 3.11, total: 6.22}
               ],
               discount_summary: [
                 %{discount_amount: 3.11, discount_name: "Buy One Get One Free Green Tea"},
                 %{discount_amount: 1.5, discount_name: "Bulk Purchase Strawberry"}
               ],
               shopping_cart_amount: 43.68,
               total_discounts: 4.61,
               final_amount: 39.07
             } = KantoxCashier.preview(user_id)
    end

    test "should return cart not found error" do
      assert {:error, :cart_not_found} == KantoxCashier.preview(22)
    end
  end
end
