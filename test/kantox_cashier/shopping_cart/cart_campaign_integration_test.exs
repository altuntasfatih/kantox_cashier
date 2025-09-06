defmodule KantoxCashier.ShoppingCart.CartCampaignIntegrationTest do
  use KantoxCashier.DataCase

  alias KantoxCashier.ShoppingCart.CartProcessor

  @given_test_scenarios %{
    scenario_1: %{
      items: [:GR1, :SR1, :GR1, :GR1, :CF1],
      expected_discounts: [{"Buy One Get One Free Green Tea", 3.11}],
      basket_amount: 25.56,
      total_discounts: 3.11,
      final_amount: 22.45
    },
    scenario_2: %{
      items: [:GR1, :GR1],
      expected_discounts: [{"Buy One Get One Free Green Tea", 3.11}],
      basket_amount: 6.22,
      total_discounts: 3.11,
      final_amount: 3.11
    },
    scenario_3: %{
      items: [:SR1, :SR1, :GR1, :SR1],
      expected_discounts: [{"Bulk Purchase Strawberry", 1.5}],
      basket_amount: 18.11,
      total_discounts: 1.5,
      final_amount: 16.61
    },
    scenario_4: %{
      items: [:GR1, :CF1, :SR1, :CF1, :CF1],
      expected_discounts: [
        {"Bulk Purchase Coffee", 11.25}
      ],
      basket_amount: 41.8,
      total_discounts: 11.25,
      final_amount: 30.55
    },
    # following are mine
    scenario_5: %{
      items: [:GR1, :CF1, :SR1, :CF1, :CF1, :GR1],
      expected_discounts: [
        {"Bulk Purchase Coffee", 11.25},
        {"Buy One Get One Free Green Tea", 3.11}
      ],
      basket_amount: 44.91,
      total_discounts: 14.36,
      final_amount: 30.55
    },
    scenario_6: %{
      items: [:GR1, :SR1, :SR1, :SR1, :GR1],
      expected_discounts: [
        {"Buy One Get One Free Green Tea", 3.11},
        {"Bulk Purchase Strawberry", 1.5}
      ],
      basket_amount: 21.22,
      total_discounts: 4.61,
      final_amount: 16.61
    },
    scenario_7: %{
      items: [:GR1, :CF1, :SR1, :CF1, :CF1, :GR1, :SR1, :SR1],
      expected_discounts: [
        {"Bulk Purchase Coffee", 11.25},
        {"Buy One Get One Free Green Tea", 3.11},
        {"Bulk Purchase Strawberry", 1.5}
      ],
      basket_amount: 54.91,
      total_discounts: 15.86,
      final_amount: 39.05
    },
    scenario_preview: %{
      items: [:GR1, :CF1, :SR1, :CF1, :CF1, :GR1],
      discount_summary: [
        %{discount_amount: 11.25, discount_name: "Bulk Purchase Coffee"},
        %{discount_amount: 3.11, discount_name: "Buy One Get One Free Green Tea"}
      ],
      basket_summary: [
        %{count: 3, total: 33.69, name: "Coffee", price: 11.23},
        %{count: 1, total: 5.0, name: "Strawberry", price: 5.0},
        %{count: 2, total: 6.22, name: "Green Tea", price: 3.11}
      ],
      basket_amount: 44.91,
      total_discounts: 14.36,
      final_amount: 30.55
    }
  }

  @user_id 1
  describe "campaign integration scenarios" do
    setup do
      {:ok, cart: CartProcessor.create_shopping_cart(@user_id)}
    end

    test "scenario 1", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_1
      expected_discounts = scenario.expected_discounts
      expected_basket_amount = scenario.basket_amount
      expected_total_discounts = scenario.total_discounts
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Product.new(item))
        end)

      # when & then
      assert %Cart{
               basket: %{
                 CF1: {1, %Product{code: :CF1, price: 11.23}},
                 GR1: {3, %Product{code: :GR1, price: 3.11}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               basket_amount: ^expected_basket_amount,
               total_discounts: ^expected_total_discounts,
               final_amount: ^expected_final_amount,
               discounts: ^expected_discounts
             } = cart
    end

    test "scenario 2", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_2
      expected_discounts = scenario.expected_discounts
      expected_basket_amount = scenario.basket_amount
      expected_total_discounts = scenario.total_discounts
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Product.new(item))
        end)

      # when & then
      assert %Cart{
               basket: %{
                 GR1: {2, %Product{code: :GR1, price: 3.11}}
               },
               basket_amount: ^expected_basket_amount,
               total_discounts: ^expected_total_discounts,
               final_amount: ^expected_final_amount,
               discounts: ^expected_discounts
             } = cart
    end

    test "scenario 3", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_3
      expected_discounts = scenario.expected_discounts
      expected_basket_amount = scenario.basket_amount
      expected_total_discounts = scenario.total_discounts
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Product.new(item))
        end)

      # when & then
      assert %Cart{
               basket: %{
                 GR1: {1, %Product{code: :GR1, price: 3.11}},
                 SR1: {3, %Product{code: :SR1, price: 5.0}}
               },
               basket_amount: ^expected_basket_amount,
               discounts: ^expected_discounts,
               total_discounts: ^expected_total_discounts,
               final_amount: ^expected_final_amount
             } = cart
    end

    test "scenario 4", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_4
      expected_discounts = scenario.expected_discounts
      expected_basket_amount = scenario.basket_amount
      expected_total_discounts = scenario.total_discounts
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Product.new(item))
        end)

      # when & then
      assert %Cart{
               user_id: @user_id,
               basket: %{
                 CF1: {3, %Product{code: :CF1, price: 11.23}},
                 GR1: {1, %Product{code: :GR1, price: 3.11}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               discounts: ^expected_discounts,
               basket_amount: ^expected_basket_amount,
               total_discounts: ^expected_total_discounts,
               final_amount: ^expected_final_amount
             } = cart
    end

    test "scenario 5", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_5
      expected_discounts = scenario.expected_discounts
      expected_basket_amount = scenario.basket_amount
      expected_total_discounts = scenario.total_discounts
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Product.new(item))
        end)

      # when & then
      assert %Cart{
               basket: %{
                 CF1: {3, %Product{code: :CF1, price: 11.23}},
                 GR1: {2, %Product{code: :GR1, price: 3.11}},
                 SR1: {1, %Product{code: :SR1, price: 5.0}}
               },
               discounts: ^expected_discounts,
               basket_amount: ^expected_basket_amount,
               total_discounts: ^expected_total_discounts,
               final_amount: ^expected_final_amount
             } = cart
    end

    test "scenario 6", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_6
      expected_discounts = scenario.expected_discounts
      expected_basket_amount = scenario.basket_amount
      expected_total_discounts = scenario.total_discounts
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Product.new(item))
        end)

      # when & then
      assert %Cart{
               basket: %{
                 GR1: {2, %Product{code: :GR1, price: 3.11}},
                 SR1: {3, %Product{code: :SR1, price: 5.0}}
               },
               discounts: ^expected_discounts,
               basket_amount: ^expected_basket_amount,
               total_discounts: ^expected_total_discounts,
               final_amount: ^expected_final_amount
             } = cart
    end

    test "scenario 7", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_7
      expected_discounts = scenario.expected_discounts
      expected_basket_amount = scenario.basket_amount
      expected_total_discounts = scenario.total_discounts
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Product.new(item))
        end)

      # when & then
      assert %Cart{
               basket: %{
                 CF1: {3, %Product{code: :CF1, price: 11.23}},
                 GR1: {2, %Product{code: :GR1, price: 3.11}},
                 SR1: {3, %Product{code: :SR1, price: 5.0}}
               },
               discounts: ^expected_discounts,
               basket_amount: ^expected_basket_amount,
               total_discounts: ^expected_total_discounts,
               final_amount: ^expected_final_amount
             } = cart
    end

    test "scenario preview", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_preview
      expected_product_summary = scenario.basket_summary
      expected_discount_summary = scenario.discount_summary
      expected_basket_amount = scenario.basket_amount
      expected_total_discounts = scenario.total_discounts
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Product.new(item))
        end)

      # when & then
      assert %{
               user_id: @user_id,
               discount_summary: ^expected_discount_summary,
               basket_summary: ^expected_product_summary,
               basket_amount: ^expected_basket_amount,
               total_discounts: ^expected_total_discounts,
               final_amount: ^expected_final_amount
             } = CartProcessor.preview(cart)
    end
  end
end
