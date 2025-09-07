defmodule KantoxCashier.ShoppingCart.CartProcessorTest do
  use KantoxCashier.DataCase

  alias KantoxCashier.ShoppingCart.CartProcessor

  @user_id 1
  describe "create_shopping_cart/1" do
    test "should create shopping cart" do
      assert CartProcessor.create_shopping_cart(@user_id) == %Cart{
               user_id: @user_id,
               basket: %{},
               basket_amount: 0.0,
               campaigns: [],
               campaigns_amount: 0.0,
               final_amount: 0.0
             }
    end
  end

  describe "add_item/2" do
    setup do
      cart = CartProcessor.create_shopping_cart(@user_id)
      {:ok, cart: cart, user_id: @user_id}
    end

    test "should add items to cart", %{cart: cart} do
      cart = CartProcessor.add_item(cart, Item.coffee())

      assert %Cart{
               basket: %{CF1: {1, %Item{code: :CF1, price: 11.23}}}
             } = cart

      cart = CartProcessor.add_item(cart, Item.strawberry())

      assert %Cart{
               basket: %{
                 CF1: {1, %Item{code: :CF1, price: 11.23}},
                 SR1: {1, %Item{code: :SR1, price: 5.0}}
               },
               campaigns: []
             } = cart

      cart = CartProcessor.add_item(cart, Item.green_tea())

      assert %Cart{
               basket: %{
                 CF1: {1, %Item{code: :CF1, price: 11.23}},
                 GR1: {1, %Item{code: :GR1, price: 3.11}},
                 SR1: {1, %Item{code: :SR1, price: 5.0}}
               },
               campaigns: []
             } = cart

      assert %Cart{
               basket: %{
                 CF1: {2, %Item{code: :CF1, price: 11.23}},
                 GR1: {1, %Item{code: :GR1, price: 3.11}},
                 SR1: {1, %Item{code: :SR1, price: 5.0}}
               },
               campaigns: []
             } = CartProcessor.add_item(cart, Item.coffee())
    end
  end

  describe "remove_item/2" do
    setup do
      cart =
        CartProcessor.create_shopping_cart(@user_id)
        |> CartProcessor.add_item(Item.coffee())
        |> CartProcessor.add_item(Item.green_tea())

      {:ok, cart: cart, user_id: @user_id}
    end

    test "should remove item", %{cart: cart} do
      # when & then
      assert %Cart{
               basket: %{
                 CF1: {1, %Item{code: :CF1, price: 11.23}}
               },
               campaigns: []
             } = CartProcessor.remove_item(cart, :GR1)
    end

    test "should remove all items", %{cart: cart} do
      # when & then
      assert %Cart{
               basket: %{},
               basket_amount: 0.0,
               campaigns: [],
               campaigns_amount: 0.0,
               final_amount: 0.0,
               user_id: @user_id
             } ==
               CartProcessor.remove_item(cart, :CF1)
               |> CartProcessor.remove_item(:GR1)
    end

    test "should ignore not existing items", %{cart: cart} do
      # when & then
      assert %Cart{
               basket: %{
                 CF1: {1, %Item{code: :CF1, price: 11.23}},
                 GR1: {1, %Item{code: :GR1, price: 3.11}}
               },
               campaigns: []
             } =
               CartProcessor.remove_item(cart, :SR1)
    end
  end

  describe "checkout/1" do
    setup do
      {:ok, cart: CartProcessor.create_shopping_cart(@user_id), user_id: @user_id}
    end

    test "should calcute empty cart", %{cart: cart} do
      assert %Cart{
               basket: %{},
               basket_amount: 0.0,
               campaigns: [],
               campaigns_amount: 0.0,
               final_amount: 0.0,
               user_id: @user_id
             } == CartProcessor.checkout(cart)
    end

    test "should calculate cart amount without campaigns", %{cart: cart} do
      # given
      cart =
        CartProcessor.add_item(cart, Item.coffee())
        |> CartProcessor.add_item(Item.green_tea())

      assert %Cart{
               basket: %{
                 CF1: {1, %Item{code: :CF1, price: 11.23}},
                 GR1: {1, %Item{code: :GR1, price: 3.11}}
               },
               campaigns: [],
               basket_amount: 14.34,
               campaigns_amount: 0.0,
               final_amount: 14.34,
               user_id: @user_id
             } == CartProcessor.checkout(cart)
    end

    test "should calculate cart amount with campaigns", %{cart: cart} do
      cart =
        CartProcessor.add_item(cart, Item.green_tea())
        |> CartProcessor.add_item(Item.green_tea())

      assert %Cart{
               user_id: @user_id,
               basket: %{GR1: {2, %Item{code: :GR1, price: 3.11}}},
               campaigns: [{"Buy One Get One Free Green Tea", 3.11}],
               basket_amount: 6.22,
               campaigns_amount: 3.11,
               final_amount: 3.11
             } == CartProcessor.checkout(cart)
    end
  end

  describe "preview/1" do
    setup do
      {:ok, cart: CartProcessor.create_shopping_cart(@user_id), user_id: @user_id}
    end

    test "should preview empty cart", %{cart: cart} do
      assert %{
               user_id: @user_id,
               basket_summary: [],
               basket_amount: 0.0,
               campaigns_summary: [],
               campaigns_amount: 0.0,
               final_amount: 0.0
             } == CartProcessor.preview(cart)
    end

    test "should preview cart with basket and no campaigns", %{cart: cart} do
      # given
      cart =
        CartProcessor.add_item(cart, Item.coffee())
        |> CartProcessor.add_item(Item.green_tea())

      # when & then
      assert %{
               user_id: @user_id,
               basket_summary: [
                 %{
                   name: "Coffee",
                   count: 1,
                   price: 11.23,
                   total: 11.23
                 },
                 %{
                   name: "Green Tea",
                   count: 1,
                   price: 3.11,
                   total: 3.11
                 }
               ],
               basket_amount: 14.34,
               campaigns_summary: [],
               campaigns_amount: 0.0,
               final_amount: 14.34
             } == CartProcessor.preview(cart)
    end

    test "should preview cart with basket and campaigns", %{cart: cart} do
      # given
      cart =
        CartProcessor.add_item(cart, Item.strawberry())
        |> CartProcessor.add_item(Item.strawberry())
        |> CartProcessor.add_item(Item.strawberry())

      # when & then
      assert %{
               user_id: @user_id,
               basket_summary: [
                 %{
                   name: "Strawberry",
                   count: 3,
                   price: 5.0,
                   total: 15.0
                 }
               ],
               basket_amount: 15.0,
               campaigns_summary: [
                 %{
                   campaign_name: "Bulk Purchase Strawberry",
                   campaigns_amount: 1.5
                 }
               ],
               campaigns_amount: 1.5,
               final_amount: 13.5
             } == CartProcessor.preview(cart)
    end
  end
end
