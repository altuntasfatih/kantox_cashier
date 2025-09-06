defmodule KantoxCashier.ShoppingCart.CartCampaignIntegrationTest do
  use KantoxCashier.DataCase

  alias KantoxCashier.ShoppingCart.CartProcessor
  alias KantoxCashier.ShoppingCart.Cart
  alias KantoxCashier.Product

  @user_id 1

  describe "campaign integration scenarios" do
    setup do
      {:ok, user_id: @user_id}
    end

    test "add GR1,SR1,GR1,GR1,CF1 - triggers green tea discount", %{user_id: user_id} do
      # given
      cart =
        create_cart(user_id)
        |> add_greentea()
        |> add_strawberry()
        |> add_greentea()
        |> add_greentea()
        |> add_coffee()

      # then
      assert cart == %Cart{
               products: %{
                 CF1: {1, %Product{code: :CF1, price: 11.23}},
                 GR1: {3, %Product{code: :GR1, price: 3.11}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               user_id: user_id,
               amount: 25.56,
               total_discounts: 3.11,
               final_amount: 22.45,
               discounts: [{"Buy One Get One Free Green Tea", 3.11}]
             }
    end

    test "add GR1,GR1 - triggers green tea discount", %{user_id: user_id} do
      # given
      cart =
        create_cart(user_id)
        |> add_greentea()
        |> add_greentea()

      # then
      assert cart == %Cart{
               user_id: user_id,
               products: %{
                 GR1: {2, %Product{code: :GR1, price: 3.11}}
               },
               discounts: [{"Buy One Get One Free Green Tea", 3.11}],
               amount: 6.22,
               total_discounts: 3.11,
               final_amount: 3.11
             }
    end

    test "add SR1,SR1,GR1,SR1 - triggers strawberry discount", %{user_id: user_id} do
      # given
      cart =
        create_cart(user_id)
        |> add_strawberry()
        |> add_strawberry()
        |> add_greentea()
        |> add_strawberry()

      # then
      assert cart == %Cart{
               user_id: user_id,
               products: %{
                 GR1: {1, %Product{code: :GR1, price: 3.11}},
                 SR1: {3, %Product{code: :SR1, price: 5.0}}
               },
               discounts: [{"Bulk Purchase Strawberry", 1.5}],
               amount: 18.11,
               total_discounts: 1.5,
               final_amount: 16.61
             }
    end

    test "add GR1,CF1,SR1,CF1,CF1 - triggers coffee discount", %{user_id: user_id} do
      # given
      cart =
        create_cart(user_id)
        |> add_greentea()
        |> add_coffee()
        |> add_strawberry()
        |> add_coffee()
        |> add_coffee()

      # then
      assert cart == %Cart{
               user_id: user_id,
               products: %{
                 CF1: {3, %Product{code: :CF1, price: 11.23}},
                 GR1: {1, %Product{code: :GR1, price: 3.11}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               discounts: [{"Bulk Purchase Coffee", 11.25}],
               amount: 41.8,
               total_discounts: 11.25,
               final_amount: 30.55
             }
    end

    test "add GR1,SR1,GR1,GR1,CF1 and then remove SR1, GR1", %{user_id: user_id} do
      # given
      cart =
        create_cart(user_id)
        |> add_greentea()
        |> add_strawberry()
        |> add_greentea()
        |> add_greentea()
        |> add_coffee()
        |> remove_strawberry()
        |> remove_greentea()

      # then
      assert cart == %Cart{
               user_id: user_id,
               products: %{
                 CF1: {1, %Product{code: :CF1, price: 11.23}},
                 GR1: {2, %Product{code: :GR1, price: 3.11}}
               },
               discounts: [{"Buy One Get One Free Green Tea", 3.11}],
               amount: 17.45,
               total_discounts: 3.11,
               final_amount: 14.34
             }
    end

    test "add GR1,CF1,SR1,CF1,CF1,GR1 - triggers coffee and green tea discounts", %{
      user_id: user_id
    } do
      # given
      cart =
        create_cart(user_id)
        |> add_greentea()
        |> add_coffee()
        |> add_strawberry()
        |> add_coffee()
        |> add_coffee()
        |> add_greentea()

      # then
      assert cart == %Cart{
               user_id: user_id,
               products: %{
                 CF1: {3, %Product{code: :CF1, price: 11.23}},
                 GR1: {2, %Product{code: :GR1, price: 3.11}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               discounts: [
                 {"Bulk Purchase Coffee", 11.25},
                 {"Buy One Get One Free Green Tea", 3.11}
               ],
               amount: 44.91,
               total_discounts: 14.36,
               final_amount: 30.55
             }
    end

    test "add GR1,CF1,SR1,CF1,CF1,GR1,SR1,SR1 - it triggers all discounts", %{user_id: user_id} do
      # given
      cart =
        create_cart(user_id)
        |> add_greentea()
        |> add_coffee()
        |> add_strawberry()
        |> add_coffee()
        |> add_coffee()
        |> add_greentea()
        |> add_strawberry()
        |> add_strawberry()

      # then
      assert cart == %Cart{
               user_id: user_id,
               products: %{
                 CF1: {3, %Product{code: :CF1, price: 11.23}},
                 GR1: {2, %Product{code: :GR1, price: 3.11}},
                 SR1: {3, %Product{code: :SR1, price: 5.0}}
               },
               discounts: [
                 {"Bulk Purchase Coffee", 11.25},
                 {"Buy One Get One Free Green Tea", 3.11},
                 {"Bulk Purchase Strawberry", 1.5}
               ],
               amount: 54.91,
               total_discounts: 15.86,
               final_amount: 39.05
             }
    end

    test "add GR1,CF1,SR1,CF1,CF1,GR1,SR1,SR1 and remove GR1,CF1", %{user_id: user_id} do
      # given
      cart =
        create_cart(user_id)
        |> add_greentea()
        |> add_coffee()
        |> add_strawberry()
        |> add_coffee()
        |> add_coffee()
        |> add_greentea()
        |> add_strawberry()
        |> add_strawberry()
        |> remove_greentea()
        |> remove_coffee()

      # then
      assert cart == %Cart{
               user_id: user_id,
               discounts: [{"Bulk Purchase Strawberry", 1.5}],
               products: %{
                 CF1: {2, %Product{code: :CF1, price: 11.23}},
                 GR1: {1, %Product{code: :GR1, price: 3.11}},
                 SR1: {3, %Product{code: :SR1, price: 5.0}}
               },
               amount: 40.57,
               total_discounts: 1.5,
               final_amount: 39.07
             }
    end

    test "add GR1,CF1,SR1,CF1,CF1,GR1 and them preview ", %{user_id: user_id} do
      # given
      cart =
        create_cart(user_id)
        |> add_greentea()
        |> add_coffee()
        |> add_strawberry()
        |> add_coffee()
        |> add_coffee()
        |> add_greentea()

      # when & then
      assert %{
               final_amount: 30.55,
               products: [
                 %{count: 3, total: 33.69, product: "Coffee", price: 11.23},
                 %{count: 1, total: 5.0, product: "Strawberry", price: 5.0},
                 %{count: 2, total: 6.22, product: "Green Tea", price: 3.11}
               ],
               total_discounts: 14.36,
               user_id: user_id,
               discount_summary: [
                 %{discount_amount: 11.25, discount_name: "Bulk Purchase Coffee"},
                 %{discount_amount: 3.11, discount_name: "Buy One Get One Free Green Tea"}
               ],
               shopping_cart_amount: 44.91
             } == CartProcessor.preview(cart)
    end
  end

  # Helper functions
  defp create_cart(user_id), do: CartProcessor.create_shopping_cart(user_id)
  defp add_coffee(cart), do: CartProcessor.add_item(cart, Product.coffee())
  defp add_strawberry(cart), do: CartProcessor.add_item(cart, Product.strawberry())
  defp add_greentea(cart), do: CartProcessor.add_item(cart, Product.green_tea())

  defp remove_greentea(cart), do: CartProcessor.remove_item(cart, :GR1)
  defp remove_coffee(cart), do: CartProcessor.remove_item(cart, :CF1)
  defp remove_strawberry(cart), do: CartProcessor.remove_item(cart, :SR1)
end
