defmodule KantoxCashierTest do
  use KantoxCashier.DataCase

  alias KantoxCashier

  describe "get_cart/1" do
    setup do
      {:ok, %{user_id: :rand.uniform(1000)}}
    end

    test "should create a cart if not exist and return it", %{user_id: user_id} do
      assert %Cart{
               user_id: user_id,
               basket: %{},
               basket_amount: 0.0,
               campaigns: [],
               campaigns_amount: 0.0,
               final_amount: 0.0
             } == KantoxCashier.get_cart(user_id)
    end

    test "should return same cart", %{user_id: user_id} do
      assert %Cart{user_id: ^user_id, campaigns: [], basket: %{}} =
               KantoxCashier.get_cart(user_id)

      assert %Cart{user_id: ^user_id, campaigns: [], basket: %{}} =
               KantoxCashier.get_cart(user_id)
    end
  end

  describe "add_item/2" do
    setup do
      {:ok, %{user_id: :rand.uniform(1000)}}
    end

    test "should add items to cart", %{user_id: user_id} do
      basket_amount = @coffee.price

      assert %Cart{
               user_id: user_id,
               basket: %{CF1: {1, @coffee}},
               basket_amount: basket_amount,
               campaigns: [],
               campaigns_amount: 0.0,
               final_amount: basket_amount
             } == KantoxCashier.add_item(user_id, :CF1)

      basket_amount = (basket_amount + @strawberry.price) |> Float.round(2)

      assert %Cart{
               user_id: user_id,
               campaigns: [],
               basket: %{
                 CF1: {1, @coffee},
                 SR1: {1, @strawberry}
               },
               basket_amount: basket_amount,
               campaigns_amount: 0.0,
               final_amount: basket_amount
             } == KantoxCashier.add_item(user_id, :SR1)

      basket_amount = basket_amount + @green_tea.price

      assert %Cart{
               user_id: user_id,
               campaigns: [],
               basket: %{
                 CF1: {1, @coffee},
                 GR1: {1, @green_tea},
                 SR1: {1, @strawberry}
               },
               basket_amount: basket_amount,
               campaigns_amount: 0.0,
               final_amount: basket_amount
             } == KantoxCashier.add_item(user_id, :GR1)
    end

    test "should return invalid item code error", %{user_id: user_id} do
      assert {:error, :invalid_item_code} == KantoxCashier.add_item(user_id, :NON_EXISTING)
    end
  end

  describe "remove_item/2" do
    setup do
      {:ok, %{user_id: :rand.uniform(1000)}}
    end

    test "should remove items from cart", %{user_id: user_id} do
      # given
      assert %{} = KantoxCashier.add_item(user_id, :CF1)
      assert %{} = KantoxCashier.add_item(user_id, :CF1)
      assert %{} = KantoxCashier.add_item(user_id, :SR1)

      # when & then
      assert %Cart{
               basket: %{CF1: {2, @coffee}}
             } = KantoxCashier.remove_item(user_id, :SR1)

      assert %Cart{
               basket: %{CF1: {1, @coffee}}
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

    test "should return cart not found error", _ do
      assert {:error, :cart_not_found} == KantoxCashier.remove_item(-1, :CF1)
    end

    test "should ignore not existing items", %{user_id: user_id} do
      assert %{} = KantoxCashier.add_item(user_id, :CF1)
      assert %{} = KantoxCashier.add_item(user_id, :CF1)

      # when & then
      assert %Cart{
               basket: %{CF1: {2, @coffee}}
             } =
               KantoxCashier.remove_item(user_id, :SR1)
    end
  end

  describe "preview/1" do
    setup do
      {:ok, %{user_id: :rand.uniform(1000)}}
    end

    test "should return the cart preview for a user", %{user_id: user_id} do
      # given
      assert %{} = KantoxCashier.add_item(user_id, :CF1)
      assert %{} = KantoxCashier.add_item(user_id, :CF1)

      assert %{} = KantoxCashier.add_item(user_id, :SR1)
      assert %{} = KantoxCashier.add_item(user_id, :SR1)
      assert %{} = KantoxCashier.add_item(user_id, :SR1)

      assert %{} = KantoxCashier.add_item(user_id, :GR1)
      assert %{} = KantoxCashier.add_item(user_id, :GR1)

      coffee_price_total = @coffee.price * 2
      strawberry_price_total = @strawberry.price * 3
      green_tea_price_total = @green_tea.price * 2

      basket_amount =
        (coffee_price_total + strawberry_price_total + green_tea_price_total) |> Float.round(2)

      campaigns_amount = 4.61
      final_amount = basket_amount - campaigns_amount

      # when & then
      assert %{
               user_id: user_id,
               basket_summary: [
                 %{name: "Coffee", count: 2, price: @coffee.price, total: coffee_price_total},
                 %{
                   name: "Strawberry",
                   count: 3,
                   price: @strawberry.price,
                   total: strawberry_price_total
                 },
                 %{
                   name: "Green Tea",
                   count: 2,
                   price: @green_tea.price,
                   total: green_tea_price_total
                 }
               ],
               campaigns_summary: [
                 %{campaigns_amount: 3.11, campaign_name: "Buy One Get One Free Green Tea"},
                 %{campaigns_amount: 1.5, campaign_name: "Bulk Purchase Strawberry"}
               ],
               basket_amount: basket_amount,
               campaigns_amount: campaigns_amount,
               final_amount: final_amount
             } == KantoxCashier.preview(user_id)
    end

    test "should return cart not found error", _ do
      assert {:error, :cart_not_found} == KantoxCashier.preview(-1)
    end
  end
end
