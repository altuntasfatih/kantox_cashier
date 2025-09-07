defmodule KantoxCashierTest do
  use KantoxCashier.DataCase

  alias KantoxCashier

  describe "start/1" do
    test "start successful" do
      assert %Cart{
               user_id: 1,
               basket: %{},
               basket_amount: 0.0,
               campaigns: [],
               campaigns_amount: 0.0,
               final_amount: 0.0
             } == KantoxCashier.start(1)

      assert %Cart{
               user_id: 12,
               basket: %{},
               basket_amount: 0.0,
               campaigns: [],
               campaigns_amount: 0.0,
               final_amount: 0.0
             } == KantoxCashier.start(12)
    end

    test "should return same cart if exist" do
      user_id = 22
      assert %Cart{user_id: ^user_id, campaigns: [], basket: %{}} = KantoxCashier.start(user_id)
      assert %Cart{user_id: ^user_id, campaigns: [], basket: %{}} = KantoxCashier.start(user_id)
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
               basket: %{CF1: {1, Item.coffee()}},
               basket_amount: Item.coffee().price,
               campaigns: [],
               campaigns_amount: 0.0,
               final_amount: Item.coffee().price
             } == KantoxCashier.add_item(user_id, :CF1)

      assert %Cart{
               user_id: user_id,
               campaigns: [],
               basket: %{
                 CF1: {1, Item.coffee()},
                 SR1: {1, Item.strawberry()}
               },
               basket_amount: 16.23,
               campaigns_amount: 0.0,
               final_amount: 16.23
             } == KantoxCashier.add_item(user_id, :SR1)

      assert %Cart{
               user_id: user_id,
               campaigns: [],
               basket: %{
                 CF1: {1, Item.coffee()},
                 GR1: {1, Item.green_tea()},
                 SR1: {1, Item.strawberry()}
               },
               basket_amount: 19.34,
               campaigns_amount: 0.0,
               final_amount: 19.34
             } == KantoxCashier.add_item(user_id, :GR1)
    end

    test "should return cart not found" do
      assert {:error, :cart_not_found} == KantoxCashier.add_item(22, :CF1)
    end

    test "should return invalid item code error", %{user_id: user_id} do
      assert {:error, :invalid_item_code} == KantoxCashier.add_item(user_id, :NON_EXISTING)
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
               basket: %{CF1: {2, %Item{code: :CF1}}}
             } = KantoxCashier.remove_item(user_id, :SR1)

      assert %Cart{
               basket: %{CF1: {1, %Item{code: :CF1}}}
             } = KantoxCashier.remove_item(user_id, :CF1)

      assert %Cart{
               user_id: user_id,
               basket: %{},
               basket_amount: 0.0,
               campaigns: [],
               campaigns_amount: 0.0,
               final_amount: 0.0
             } ==
               KantoxCashier.remove_item(user_id, :CF1)
    end

    test "should ignore not existing items", %{user_id: user_id} do
      assert %Cart{
               user_id: user_id,
               campaigns: [],
               basket: %{},
               basket_amount: 0.0,
               campaigns_amount: 0.0,
               final_amount: 0.0
             } ==
               KantoxCashier.remove_item(user_id, :CF1)
    end
  end

  describe "get_cart/1" do
    test "should return the cart for a user" do
      user_id = 12
      assert %{} = KantoxCashier.start(user_id)

      assert %Cart{user_id: ^user_id, basket: %{}, campaigns: []} =
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
               basket_summary: [
                 %{name: "Coffee", count: 2, price: 11.23, total: 22.46},
                 %{name: "Strawberry", count: 3, price: 5.0, total: 15.0},
                 %{name: "Green Tea", count: 2, price: 3.11, total: 6.22}
               ],
               campaigns_summary: [
                 %{campaigns_amount: 3.11, campaign_name: "Buy One Get One Free Green Tea"},
                 %{campaigns_amount: 1.5, campaign_name: "Bulk Purchase Strawberry"}
               ],
               basket_amount: 43.68,
               campaigns_amount: 4.61,
               final_amount: 39.07
             } = KantoxCashier.preview(user_id)
    end

    test "should return cart not found error" do
      assert {:error, :cart_not_found} == KantoxCashier.preview(22)
    end
  end
end
