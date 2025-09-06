defmodule KantoxCashier.ShoppingCart.CartProcessorTest do
  alias KantoxCashier.Campaign.BulkPurchaseStrawberry
  alias KantoxCashier.Campaign.BuyOneGetOneFreeGreentea
  alias KantoxCashier.Campaign.BulkPurchaseCoffee
  use KantoxCashier.DataCase
  alias KantoxCashier.ShoppingCart.CartProcessor

  describe "cashier module test" do
    test "create_shopping_cart/1" do
      assert CartProcessor.create_shopping_cart(1) == %Cart{
               discounts: [],
               user_id: 1,
               products: %{},
               amount: 0.0,
               total: 0.0
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
               total: 22.45,
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
               products: %{
                 GR1: {2, %Product{code: :GR1, price: 3.11}}
               },
               user_id: user_id,
               amount: 6.22,
               total: 3.11,
               discounts: [{BuyOneGetOneFreeGreentea.name(), 3.11}]
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
               products: %{
                 GR1: {1, %Product{code: :GR1, price: 3.11}},
                 SR1: {3, %Product{code: :SR1, price: 5.0}}
               },
               user_id: user_id,
               amount: 18.11,
               total: 16.61,
               discounts: [{BulkPurchaseStrawberry.name(), 1.5}]
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
               products: %{
                 CF1: {3, %Product{code: :CF1, price: 11.23}},
                 GR1: {1, %Product{code: :GR1, price: 3.11}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               user_id: user_id,
               amount: 41.8,
               total: 30.55,
               discounts: [{BulkPurchaseCoffee.name(), 11.25}]
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
               products: %{
                 CF1: {1, %Product{code: :CF1, price: 11.23}},
                 GR1: {2, %Product{code: :GR1, price: 3.11}}
               },
               user_id: user_id,
               amount: 17.45,
               total: 14.34,
               discounts: [{BuyOneGetOneFreeGreentea.name(), 3.11}]
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
               products: %{
                 CF1: {3, %Product{code: :CF1, price: 11.23}},
                 GR1: {2, %Product{code: :GR1, price: 3.11}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               user_id: user_id,
               amount: 44.91,
               total: 30.55,
               discounts: [
                 {BulkPurchaseCoffee.name(), 11.25},
                 {BuyOneGetOneFreeGreentea.name(), 3.11}
               ]
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
               products: %{
                 CF1: {3, %Product{code: :CF1, price: 11.23}},
                 GR1: {2, %Product{code: :GR1, price: 3.11}},
                 SR1: {3, %Product{code: :SR1, price: 5.0}}
               },
               user_id: user_id,
               amount: 54.91,
               total: 39.05,
               discounts: [
                 {BulkPurchaseCoffee.name(), 11.25},
                 {BuyOneGetOneFreeGreentea.name(), 3.11},
                 {BulkPurchaseStrawberry.name(), 1.5}
               ]
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
               products: %{
                 CF1: {2, %Product{code: :CF1, price: 11.23}},
                 GR1: {1, %Product{code: :GR1, price: 3.11}},
                 SR1: {3, %Product{code: :SR1, price: 5.0}}
               },
               user_id: user_id,
               amount: 40.57,
               total: 39.07,
               discounts: [{BulkPurchaseStrawberry.name(), 1.5}]
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
