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
      cart = CartProcessor.add_item(cart, @coffee)

      assert %Cart{
               basket: %{CF1: {1, @coffee}}
             } = cart

      cart = CartProcessor.add_item(cart, @strawberry)

      assert %Cart{
               basket: %{
                 CF1: {1, @coffee},
                 SR1: {1, @strawberry}
               },
               campaigns: []
             } = cart

      cart = CartProcessor.add_item(cart, @green_tea)

      assert %Cart{
               basket: %{
                 CF1: {1, @coffee},
                 GR1: {1, @green_tea},
                 SR1: {1, @strawberry}
               },
               campaigns: []
             } = cart

      assert %Cart{
               basket: %{
                 CF1: {2, @coffee},
                 GR1: {1, @green_tea},
                 SR1: {1, @strawberry}
               },
               campaigns: []
             } = CartProcessor.add_item(cart, @coffee)
    end
  end

  describe "remove_item/2" do
    setup do
      cart =
        CartProcessor.create_shopping_cart(@user_id)
        |> CartProcessor.add_item(@coffee)
        |> CartProcessor.add_item(@green_tea)

      {:ok, cart: cart, user_id: @user_id}
    end

    test "should remove item", %{cart: cart} do
      # when & then
      assert %Cart{
               basket: %{
                 CF1: {1, @coffee}
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
                 CF1: {1, @coffee},
                 GR1: {1, @green_tea}
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

    test "should calculate empty cart", %{cart: cart} do
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
      expected_basket_amount = (@coffee.price + @green_tea.price) |> Float.round(2)
      expected_campaigns_amount = 0.0
      expected_final_amount = expected_basket_amount

      # when
      cart =
        CartProcessor.add_item(cart, @coffee)
        |> CartProcessor.add_item(@green_tea)

      # then
      assert %Cart{
               basket: %{
                 CF1: {1, @coffee},
                 GR1: {1, @green_tea}
               },
               campaigns: [],
               basket_amount: expected_basket_amount,
               campaigns_amount: expected_campaigns_amount,
               final_amount: expected_final_amount,
               user_id: @user_id
             } == CartProcessor.checkout(cart)
    end

    test "should calculate cart amount with campaign", %{cart: cart} do
      # given
      expected_basket_amount = @green_tea.price * 2
      expected_campaigns_amount = 3.11
      campaings = [{"Buy One Get One Free Green Tea", expected_campaigns_amount}]
      expected_final_amount = expected_basket_amount - expected_campaigns_amount

      # when
      cart =
        CartProcessor.add_item(cart, @green_tea)
        |> CartProcessor.add_item(@green_tea)

      # then
      assert %Cart{
               user_id: @user_id,
               basket: %{GR1: {2, @green_tea}},
               campaigns: campaings,
               basket_amount: expected_basket_amount,
               campaigns_amount: expected_campaigns_amount,
               final_amount: expected_final_amount
             } == CartProcessor.checkout(cart)
    end
  end

  describe "preview/1" do
    setup do
      {:ok, cart: CartProcessor.create_shopping_cart(@user_id)}
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

    test "should preview cart with basket and no campaign", %{cart: cart} do
      # given
      basket_amount = @coffee.price + @green_tea.price

      cart =
        CartProcessor.add_item(cart, @coffee)
        |> CartProcessor.add_item(@green_tea)

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
               basket_amount: basket_amount,
               campaigns_summary: [],
               campaigns_amount: 0.0,
               final_amount: basket_amount
             } == CartProcessor.preview(cart)
    end

    test "should preview cart with basket and campaign", %{cart: cart} do
      # given
      strawberry_count = 3
      basket_amount = @strawberry.price * strawberry_count
      campaigns_amount = 1.5
      final_amount = basket_amount - campaigns_amount

      # when
      cart =
        CartProcessor.add_item(cart, @strawberry)
        |> CartProcessor.add_item(@strawberry)
        |> CartProcessor.add_item(@strawberry)

      # then
      assert %{
               user_id: @user_id,
               basket_summary: [
                 %{
                   name: "Strawberry",
                   count: strawberry_count,
                   price: @strawberry.price,
                   total: basket_amount
                 }
               ],
               basket_amount: basket_amount,
               campaigns_summary: [
                 %{
                   campaign_name: "Bulk Purchase Strawberry",
                   campaigns_amount: campaigns_amount
                 }
               ],
               campaigns_amount: campaigns_amount,
               final_amount: final_amount
             } == CartProcessor.preview(cart)
    end
  end
end
