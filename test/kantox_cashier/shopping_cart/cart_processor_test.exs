defmodule KantoxCashier.ShoppingCart.CartProcessorTest do
  use KantoxCashier.DataCase

  alias KantoxCashier.ShoppingCart.CartProcessor

  describe "cashier module test" do
    test "create_shopping_cart/1" do
      assert CartProcessor.create_shopping_cart(1) == %Cart{
               user_id: 1,
               products: %{},
               discounts: [],
               amount: 0.0,
               total_discounts: 0.0,
               final_amount: 0.0
             }
    end

    test "add_item/2" do
      cart = CartProcessor.create_shopping_cart(1)
      cart = CartProcessor.add_item(cart, Product.new(:CF1))

      assert %Cart{
               products: %{CF1: {1, %Product{code: :CF1, price: 11.23}}},
               user_id: 1
             } = cart

      cart = CartProcessor.add_item(cart, Product.new(:SR1))

      assert %Cart{
               products: %{
                 CF1: {1, %Product{code: :CF1, price: 11.23}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               user_id: 1
             } = cart

      cart = CartProcessor.add_item(cart, Product.new(:GR1))

      assert %Cart{
               products: %{
                 CF1: {1, %Product{code: :CF1, price: 11.23}},
                 GR1: {1, %Product{code: :GR1, price: 3.11}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               user_id: 1
             } = cart

      assert %Cart{
               products: %{
                 CF1: {2, %Product{code: :CF1, price: 11.23}},
                 GR1: {1, %Product{code: :GR1, price: 3.11}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               user_id: 1
             } = CartProcessor.add_item(cart, Product.new(:CF1))
    end

    test "remove_item/2" do
      cart =
        CartProcessor.create_shopping_cart(1)
        |> CartProcessor.add_item(Product.new(:CF1))
        |> CartProcessor.add_item(Product.new(:CF1))
        |> CartProcessor.add_item(Product.new(:GR1))

      assert %Cart{
               products: %{
                 CF1: {1, %Product{code: :CF1, price: 11.23}},
                 GR1: {1, %Product{code: :GR1, price: 3.11}}
               },
               user_id: 1
             } = CartProcessor.remove_item(cart, :CF1)

      assert %Cart{
               products: %{GR1: {1, %Product{code: :GR1, price: 3.11}}},
               user_id: 1,
               discounts: []
             } = CartProcessor.remove_item(cart, :CF1)
    end

    test "preview/1" do
      # given
      user_id = 1

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
               user_id: 1,
               discount_summary: [
                 %{discount_amount: 11.25, discount_name: "Bulk Purchase Coffee"},
                 %{discount_amount: 3.11, discount_name: "Buy One Get One Free Green Tea"}
               ],
               shopping_cart_amount: 44.91
             } == CartProcessor.preview(cart)
    end
  end

  describe "test inputs" do
    test "add GR1,SR1,GR1,GR1,CF1" do
      # given
      user_id = 1

      cart =
        create_cart(user_id)
        |> add_greentea()
        |> add_strawberry()
        |> add_greentea()
        |> add_greentea()
        |> add_coffee()

      # when & then
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
               discounts: [{BuyOneGetOneFreeGreentea.name(), 3.11}]
             }
    end

    test "add GR1,GR1" do
      # given
      user_id = 1

      cart =
        create_cart(user_id)
        |> add_greentea()
        |> add_greentea()

      # when & then
      assert cart == %Cart{
               user_id: user_id,
               products: %{
                 GR1: {2, %Product{code: :GR1, price: 3.11}}
               },
               discounts: [{BuyOneGetOneFreeGreentea.name(), 3.11}],
               amount: 6.22,
               total_discounts: 3.11,
               final_amount: 3.11
             }
    end

    test "add SR1,SR1,GR1,SR1" do
      # given
      user_id = 1

      cart =
        create_cart(user_id)
        |> add_strawberry()
        |> add_strawberry()
        |> add_greentea()
        |> add_strawberry()

      # when & then
      assert cart == %Cart{
               user_id: user_id,
               products: %{
                 GR1: {1, %Product{code: :GR1, price: 3.11}},
                 SR1: {3, %Product{code: :SR1, price: 5.0}}
               },
               discounts: [{BulkPurchaseStrawberry.name(), 1.5}],
               amount: 18.11,
               total_discounts: 1.5,
               final_amount: 16.61
             }
    end

    test "add GR1,CF1,SR1,CF1,CF1" do
      # given
      user_id = 1

      cart =
        create_cart(user_id)
        |> add_greentea()
        |> add_coffee()
        |> add_strawberry()
        |> add_coffee()
        |> add_coffee()

      # when & then
      assert cart == %Cart{
               user_id: user_id,
               products: %{
                 CF1: {3, %Product{code: :CF1, price: 11.23}},
                 GR1: {1, %Product{code: :GR1, price: 3.11}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               discounts: [{BulkPurchaseCoffee.name(), 11.25}],
               amount: 41.8,
               total_discounts: 11.25,
               final_amount: 30.55
             }
    end

    test "add GR1,SR1,GR1,GR1,CF1 and then remove SR1, GR1" do
      # given
      user_id = 1

      cart =
        create_cart(user_id)
        |> add_greentea()
        |> add_strawberry()
        |> add_greentea()
        |> add_greentea()
        |> add_coffee()
        |> remove_strawberry()
        |> remove_greentea()

      # when & then
      assert cart == %Cart{
               user_id: user_id,
               products: %{
                 CF1: {1, %Product{code: :CF1, price: 11.23}},
                 GR1: {2, %Product{code: :GR1, price: 3.11}}
               },
               discounts: [{BuyOneGetOneFreeGreentea.name(), 3.11}],
               amount: 17.45,
               total_discounts: 3.11,
               final_amount: 14.34
             }
    end

    test "GR1,CF1,SR1,CF1,CF1,GR1" do
      # given
      user_id = 1

      cart =
        create_cart(user_id)
        |> add_greentea()
        |> add_coffee()
        |> add_strawberry()
        |> add_coffee()
        |> add_coffee()
        |> add_greentea()

      # when & then
      assert cart == %Cart{
               user_id: user_id,
               products: %{
                 CF1: {3, %Product{code: :CF1, price: 11.23}},
                 GR1: {2, %Product{code: :GR1, price: 3.11}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               discounts: [
                 {BulkPurchaseCoffee.name(), 11.25},
                 {BuyOneGetOneFreeGreentea.name(), 3.11}
               ],
               amount: 44.91,
               total_discounts: 14.36,
               final_amount: 30.55
             }
    end

    test "GR1,CF1,SR1,CF1,CF1,GR1,SR1,SR1" do
      # given
      user_id = 1

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

      # when & then
      assert cart == %Cart{
               user_id: user_id,
               products: %{
                 CF1: {3, %Product{code: :CF1, price: 11.23}},
                 GR1: {2, %Product{code: :GR1, price: 3.11}},
                 SR1: {3, %Product{code: :SR1, price: 5.0}}
               },
               discounts: [
                 {BulkPurchaseCoffee.name(), 11.25},
                 {BuyOneGetOneFreeGreentea.name(), 3.11},
                 {BulkPurchaseStrawberry.name(), 1.5}
               ],
               amount: 54.91,
               total_discounts: 15.86,
               final_amount: 39.05
             }
    end

    test "GR1,CF1,SR1,CF1,CF1,GR1,SR1,SR1 and remove GR1,CF1" do
      # given
      user_id = 1

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

      # when & then
      assert cart == %Cart{
               user_id: user_id,
               discounts: [{BulkPurchaseStrawberry.name(), 1.5}],
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
  end

  defp create_cart(user_id), do: CartProcessor.create_shopping_cart(user_id)
  defp add_coffee(chart), do: CartProcessor.add_item(chart, Product.new(:CF1))
  defp add_strawberry(chart), do: CartProcessor.add_item(chart, Product.new(:SR1))
  defp add_greentea(chart), do: CartProcessor.add_item(chart, Product.new(:GR1))
  defp remove_greentea(chart), do: CartProcessor.remove_item(chart, :GR1)
  defp remove_coffee(chart), do: CartProcessor.remove_item(chart, :CF1)
  defp remove_strawberry(chart), do: CartProcessor.remove_item(chart, :SR1)
end
