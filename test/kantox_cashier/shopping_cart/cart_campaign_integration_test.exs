defmodule KantoxCashier.ShoppingCart.CartCampaignIntegrationTest do
  use KantoxCashier.DataCase

  alias KantoxCashier.ShoppingCart.CartProcessor

  @given_test_scenarios %{
    scenario_1: %{
      items: [:GR1, :SR1, :GR1, :GR1, :CF1],
      expected_campaigns: [{"Buy One Get One Free Green Tea", 3.11}],
      basket_amount: 25.56,
      campaigns_amount: 3.11,
      final_amount: 22.45
    },
    scenario_2: %{
      items: [:GR1, :GR1],
      expected_campaigns: [{"Buy One Get One Free Green Tea", 3.11}],
      basket_amount: 6.22,
      campaigns_amount: 3.11,
      final_amount: 3.11
    },
    scenario_3: %{
      items: [:SR1, :SR1, :GR1, :SR1],
      expected_campaigns: [{"Bulk Purchase Strawberry", 1.5}],
      basket_amount: 18.11,
      campaigns_amount: 1.5,
      final_amount: 16.61
    },
    scenario_4: %{
      items: [:GR1, :CF1, :SR1, :CF1, :CF1],
      expected_campaigns: [
        {"Bulk Purchase Coffee", 11.25}
      ],
      basket_amount: 41.8,
      campaigns_amount: 11.25,
      final_amount: 30.55
    },
    # following are mine
    scenario_5: %{
      items: [:GR1, :CF1, :SR1, :CF1, :CF1, :GR1],
      expected_campaigns: [
        {"Bulk Purchase Coffee", 11.25},
        {"Buy One Get One Free Green Tea", 3.11}
      ],
      basket_amount: 44.91,
      campaigns_amount: 14.36,
      final_amount: 30.55
    },
    scenario_6: %{
      items: [:GR1, :SR1, :SR1, :SR1, :GR1],
      expected_campaigns: [
        {"Buy One Get One Free Green Tea", 3.11},
        {"Bulk Purchase Strawberry", 1.5}
      ],
      basket_amount: 21.22,
      campaigns_amount: 4.61,
      final_amount: 16.61
    },
    scenario_7: %{
      items: [:GR1, :CF1, :SR1, :CF1, :CF1, :GR1, :SR1, :SR1],
      expected_campaigns: [
        {"Bulk Purchase Coffee", 11.25},
        {"Buy One Get One Free Green Tea", 3.11},
        {"Bulk Purchase Strawberry", 1.5}
      ],
      basket_amount: 54.91,
      campaigns_amount: 15.86,
      final_amount: 39.05
    },
    scenario_8: %{
      items: [:GR1, :CF1, :SR1],
      expected_campaigns: [],
      basket_amount: 19.34,
      campaigns_amount: 0.0,
      final_amount: 19.34
    },
    scenario_9: %{
      items: [:GR1],
      expected_campaigns: [],
      basket_amount: 3.11,
      campaigns_amount: 0.0,
      final_amount: 3.11
    },
    scenario_10: %{
      items: [:CF1],
      expected_campaigns: [],
      basket_amount: 11.23,
      campaigns_amount: 0.0,
      final_amount: 11.23
    },
    scenario_11: %{
      items: [:SR1],
      expected_campaigns: [],
      basket_amount: 5.0,
      campaigns_amount: 0.0,
      final_amount: 5.0
    },
    scenario_preview: %{
      items: [:GR1, :CF1, :SR1, :CF1, :CF1, :GR1],
      campaigns_summary: [
        %{campaigns_amount: 11.25, campaign_name: "Bulk Purchase Coffee"},
        %{campaigns_amount: 3.11, campaign_name: "Buy One Get One Free Green Tea"}
      ],
      basket_summary: [
        %{count: 3, total: 33.69, name: "Coffee", price: 11.23},
        %{count: 1, total: 5.0, name: "Strawberry", price: 5.0},
        %{count: 2, total: 6.22, name: "Green Tea", price: 3.11}
      ],
      basket_amount: 44.91,
      campaigns_amount: 14.36,
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
      expected_campaigns = scenario.expected_campaigns
      expected_basket_amount = scenario.basket_amount
      expected_campaigns_amount = scenario.campaigns_amount
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Item.new(item))
        end)

      # when & then
      assert %Cart{
               basket: %{
                 CF1: {1, %Item{code: :CF1, price: 11.23}},
                 GR1: {3, %Item{code: :GR1, price: 3.11}},
                 SR1: {1, %Item{code: :SR1, price: 5.0}}
               },
               basket_amount: ^expected_basket_amount,
               campaigns: ^expected_campaigns,
               campaigns_amount: ^expected_campaigns_amount,
               final_amount: ^expected_final_amount
             } = cart
    end

    test "scenario 2", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_2
      expected_campaigns = scenario.expected_campaigns
      expected_basket_amount = scenario.basket_amount
      expected_campaigns_amount = scenario.campaigns_amount
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Item.new(item))
        end)

      # when & then
      assert %Cart{
               basket: %{
                 GR1: {2, %Item{code: :GR1, price: 3.11}}
               },
               basket_amount: ^expected_basket_amount,
               campaigns: ^expected_campaigns,
               campaigns_amount: ^expected_campaigns_amount,
               final_amount: ^expected_final_amount
             } = cart
    end

    test "scenario 3", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_3
      expected_campaigns = scenario.expected_campaigns
      expected_basket_amount = scenario.basket_amount
      expected_campaigns_amount = scenario.campaigns_amount
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Item.new(item))
        end)

      # when & then
      assert %Cart{
               basket: %{
                 GR1: {1, %Item{code: :GR1, price: 3.11}},
                 SR1: {3, %Item{code: :SR1, price: 5.0}}
               },
               basket_amount: ^expected_basket_amount,
               campaigns: ^expected_campaigns,
               campaigns_amount: ^expected_campaigns_amount,
               final_amount: ^expected_final_amount
             } = cart
    end

    test "scenario 4", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_4
      expected_campaigns = scenario.expected_campaigns
      expected_basket_amount = scenario.basket_amount
      expected_campaigns_amount = scenario.campaigns_amount
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Item.new(item))
        end)

      # when & then
      assert %Cart{
               user_id: @user_id,
               basket: %{
                 CF1: {3, %Item{code: :CF1, price: 11.23}},
                 GR1: {1, %Item{code: :GR1, price: 3.11}},
                 SR1: {1, %Item{code: :SR1, price: 5.0}}
               },
               basket_amount: ^expected_basket_amount,
               campaigns: ^expected_campaigns,
               campaigns_amount: ^expected_campaigns_amount,
               final_amount: ^expected_final_amount
             } = cart
    end

    test "scenario 5", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_5
      expected_campaigns = scenario.expected_campaigns
      expected_basket_amount = scenario.basket_amount
      expected_campaigns_amount = scenario.campaigns_amount
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Item.new(item))
        end)

      # when & then
      assert %Cart{
               basket: %{
                 CF1: {3, %Item{code: :CF1, price: 11.23}},
                 GR1: {2, %Item{code: :GR1, price: 3.11}},
                 SR1: {1, %Item{code: :SR1, price: 5.0}}
               },
               basket_amount: ^expected_basket_amount,
               campaigns: ^expected_campaigns,
               campaigns_amount: ^expected_campaigns_amount,
               final_amount: ^expected_final_amount
             } = cart
    end

    test "scenario 6", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_6
      expected_campaigns = scenario.expected_campaigns
      expected_basket_amount = scenario.basket_amount
      expected_campaigns_amount = scenario.campaigns_amount
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Item.new(item))
        end)

      # when & then
      assert %Cart{
               basket: %{
                 GR1: {2, %Item{code: :GR1, price: 3.11}},
                 SR1: {3, %Item{code: :SR1, price: 5.0}}
               },
               basket_amount: ^expected_basket_amount,
               campaigns: ^expected_campaigns,
               campaigns_amount: ^expected_campaigns_amount,
               final_amount: ^expected_final_amount
             } = cart
    end

    test "scenario 7", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_7
      expected_campaigns = scenario.expected_campaigns
      expected_basket_amount = scenario.basket_amount
      expected_campaigns_amount = scenario.campaigns_amount
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Item.new(item))
        end)

      # when & then
      assert %Cart{
               basket: %{
                 CF1: {3, %Item{code: :CF1, price: 11.23}},
                 GR1: {2, %Item{code: :GR1, price: 3.11}},
                 SR1: {3, %Item{code: :SR1, price: 5.0}}
               },
               campaigns: ^expected_campaigns,
               basket_amount: ^expected_basket_amount,
               campaigns_amount: ^expected_campaigns_amount,
               final_amount: ^expected_final_amount
             } = cart
    end

    test "scenario 8", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_8
      expected_campaigns = scenario.expected_campaigns
      expected_basket_amount = scenario.basket_amount
      expected_campaigns_amount = scenario.campaigns_amount
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Item.new(item))
        end)

      # when & then
      assert %Cart{
               basket: %{
                 CF1: {1, %Item{code: :CF1, price: 11.23}},
                 GR1: {1, %Item{code: :GR1, price: 3.11}},
                 SR1: {1, %Item{code: :SR1, price: 5.0}}
               },
               basket_amount: ^expected_basket_amount,
               campaigns: ^expected_campaigns,
               campaigns_amount: ^expected_campaigns_amount,
               final_amount: ^expected_final_amount
             } = cart
    end

    test "scenario 9", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_9
      expected_campaigns = scenario.expected_campaigns
      expected_basket_amount = scenario.basket_amount
      expected_campaigns_amount = scenario.campaigns_amount
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Item.new(item))
        end)

      # when & then
      assert %Cart{
               basket: %{
                 GR1: {1, %Item{code: :GR1, price: 3.11}}
               },
               basket_amount: ^expected_basket_amount,
               campaigns: ^expected_campaigns,
               campaigns_amount: ^expected_campaigns_amount,
               final_amount: ^expected_final_amount
             } = cart
    end

    test "scenario 10", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_10
      expected_campaigns = scenario.expected_campaigns
      expected_basket_amount = scenario.basket_amount
      expected_campaigns_amount = scenario.campaigns_amount
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Item.new(item))
        end)

      # when & then
      assert %Cart{
               basket: %{
                 CF1: {1, %Item{code: :CF1, price: 11.23}}
               },
               basket_amount: ^expected_basket_amount,
               campaigns: ^expected_campaigns,
               campaigns_amount: ^expected_campaigns_amount,
               final_amount: ^expected_final_amount
             } = cart
    end

    test "scenario 11", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_11
      expected_campaigns = scenario.expected_campaigns
      expected_basket_amount = scenario.basket_amount
      expected_campaigns_amount = scenario.campaigns_amount
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Item.new(item))
        end)

      # when & then
      assert %Cart{
               basket: %{
                 SR1: {1, %Item{code: :SR1, price: 5.0}}
               },
               basket_amount: ^expected_basket_amount,
               campaigns: ^expected_campaigns,
               campaigns_amount: ^expected_campaigns_amount,
               final_amount: ^expected_final_amount
             } = cart
    end

    test "scenario preview", %{cart: cart} do
      # given
      scenario = @given_test_scenarios.scenario_preview
      expected_item_summary = scenario.basket_summary
      expected_campaigns_summary = scenario.campaigns_summary
      expected_basket_amount = scenario.basket_amount
      expected_campaigns_amount = scenario.campaigns_amount
      expected_final_amount = scenario.final_amount

      cart =
        Enum.reduce(scenario.items, cart, fn item, cart ->
          CartProcessor.add_item(cart, Item.new(item))
        end)

      # when & then
      assert %{
               user_id: @user_id,
               basket_summary: ^expected_item_summary,
               basket_amount: ^expected_basket_amount,
               campaigns_summary: ^expected_campaigns_summary,
               campaigns_amount: ^expected_campaigns_amount,
               final_amount: ^expected_final_amount
             } = CartProcessor.preview(cart)
    end
  end
end
