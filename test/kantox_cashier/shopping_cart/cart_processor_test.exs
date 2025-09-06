defmodule KantoxCashier.ShoppingCart.CartProcessorTest do
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
      cart = CartProcessor.add_item(cart, :CF1)

      assert %Cart{
               products: %{CF1: {1, %Product{code: :CF1, price: 11.23}}},
               user_id: 1
             } = cart

      cart = CartProcessor.add_item(cart, :SR1)

      assert %Cart{
               products: %{
                 CF1: {1, %Product{code: :CF1, price: 11.23}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               user_id: 1
             } = cart

      cart = CartProcessor.add_item(cart, :GR1)

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
             } = CartProcessor.add_item(cart, :CF1)
    end

    test "remove_item/2" do
      cart =
        CartProcessor.create_shopping_cart(1)
        |> CartProcessor.add_item(:CF1)
        |> CartProcessor.add_item(:CF1)
        |> CartProcessor.add_item(:GR1)

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
    test "GR1,SR1,GR1,GR1,CF1" do
      cart =
        CartProcessor.create_shopping_cart(1)
        |> CartProcessor.add_item(:GR1)
        |> CartProcessor.add_item(:SR1)
        |> CartProcessor.add_item(:GR1)
        |> CartProcessor.add_item(:GR1)
        |> CartProcessor.add_item(:CF1)

      assert cart == %Cart{
               products: %{
                 CF1: {1, %Product{code: :CF1, price: 11.23}},
                 GR1: {3, %Product{code: :GR1, price: 3.11}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               user_id: 1,
               amount: 25.56,
               total: 22.45,
               discounts: [3.11]
             }
    end

    test "GR1,GR1" do
      cart =
        CartProcessor.create_shopping_cart(1)
        |> CartProcessor.add_item(:GR1)
        |> CartProcessor.add_item(:GR1)

      assert cart == %Cart{
               products: %{
                 GR1: {2, %Product{code: :GR1, price: 3.11}}
               },
               user_id: 1,
               amount: 6.22,
               total: 3.11,
               discounts: [3.11]
             }
    end

    test "SR1,SR1,GR1,SR1" do
      cart =
        CartProcessor.create_shopping_cart(1)
        |> CartProcessor.add_item(:SR1)
        |> CartProcessor.add_item(:SR1)
        |> CartProcessor.add_item(:GR1)
        |> CartProcessor.add_item(:SR1)

      assert cart == %Cart{
               products: %{
                 GR1: {1, %Product{code: :GR1, price: 3.11}},
                 SR1: {3, %Product{code: :SR1, price: 5.0}}
               },
               user_id: 1,
               amount: 18.11,
               total: 16.61,
               discounts: [1.5]
             }
    end

    test "GR1,CF1,SR1,CF1,CF1" do
      cart =
        CartProcessor.create_shopping_cart(1)
        |> CartProcessor.add_item(:GR1)
        |> CartProcessor.add_item(:CF1)
        |> CartProcessor.add_item(:SR1)
        |> CartProcessor.add_item(:CF1)
        |> CartProcessor.add_item(:CF1)

      assert cart == %Cart{
               products: %{
                 CF1: {3, %Product{code: :CF1, price: 11.23}},
                 GR1: {1, %Product{code: :GR1, price: 3.11}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               user_id: 1,
               amount: 41.8,
               total: 30.55,
               discounts: [11.25]
             }
    end
  end

  describe "different flows" do
    test "add GR1,SR1,GR1,GR1,CF1 and then SR1, GR1" do
      cart =
        CartProcessor.create_shopping_cart(1)
        |> CartProcessor.add_item(:GR1)
        |> CartProcessor.add_item(:SR1)
        |> CartProcessor.add_item(:GR1)
        |> CartProcessor.add_item(:GR1)
        |> CartProcessor.add_item(:CF1)
        |> CartProcessor.remove_item(:SR1)
        |> CartProcessor.remove_item(:GR1)

      assert cart == %Cart{
               products: %{
                 CF1: {1, %Product{code: :CF1, price: 11.23}},
                 GR1: {2, %Product{code: :GR1, price: 3.11}}
               },
               user_id: 1,
               amount: 17.45,
               total: 14.34,
               discounts: [3.11]
             }
    end

    test "GR1,CF1,SR1,CF1,CF1,GR1" do
      cart =
        CartProcessor.create_shopping_cart(1)
        |> CartProcessor.add_item(:GR1)
        |> CartProcessor.add_item(:CF1)
        |> CartProcessor.add_item(:SR1)
        |> CartProcessor.add_item(:CF1)
        |> CartProcessor.add_item(:CF1)
        |> CartProcessor.add_item(:GR1)

      assert cart == %Cart{
               products: %{
                 CF1: {3, %Product{code: :CF1, price: 11.23}},
                 GR1: {2, %Product{code: :GR1, price: 3.11}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               user_id: 1,
               amount: 44.91,
               total: 30.55,
               discounts: [3.11, 11.25]
             }
    end

    test "GR1,CF1,SR1,CF1,CF1,GR1,SR1,SR1" do
      cart =
        CartProcessor.create_shopping_cart(1)
        |> CartProcessor.add_item(:GR1)
        |> CartProcessor.add_item(:CF1)
        |> CartProcessor.add_item(:SR1)
        |> CartProcessor.add_item(:CF1)
        |> CartProcessor.add_item(:CF1)
        |> CartProcessor.add_item(:GR1)
        |> CartProcessor.add_item(:SR1)
        |> CartProcessor.add_item(:SR1)

      assert cart == %Cart{
               products: %{
                 CF1: {3, %Product{code: :CF1, price: 11.23}},
                 GR1: {2, %Product{code: :GR1, price: 3.11}},
                 SR1: {3, %Product{code: :SR1, price: 5.0}}
               },
               user_id: 1,
               amount: 54.91,
               total: 39.05,
               discounts: [1.50, 3.11, 11.25]
             }
    end
  end
end
