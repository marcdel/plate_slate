defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    PlateSlate.Seeds.run()
  end

  @query """
  {
    menuItems {
      name,
      price
    }
  }
  """
  test "menuItems field returns menu items" do
    items =
      build_conn()
      |> get("/api", query: @query)
      |> json_response(200)
      |> menu_items_from_response()

    Enum.each(items, fn item ->
      assert %{"name" => _, "price" => _} = item
    end)
  end

  @query """
  {
    menuItems(matching: "reu") {
      name
    }
  }
  """
  test "menuItems field returns menu items filtered by name" do
    items =
      build_conn()
      |> get("/api", query: @query)
      |> json_response(200)
      |> menu_items_from_response()

    assert items == [%{"name" => "Reuben"}]
  end

  @query """
  query ($term: String) {
    menuItems(matching: $term) {
      name
    }
  }
  """
  @variables %{"term" => "reu"}
  test "menuItems field filters by name when using a variable" do
    items =
      build_conn()
      |> get("/api", query: @query, variables: @variables)
      |> json_response(200)
      |> menu_items_from_response()

    assert items == [%{"name" => "Reuben"}]
  end

  @query """
  {
    menuItems(matching: 123) {
      name
    }
  }
  """
  test "menuItems field returns errors when using a bad value" do
    response =
      build_conn()
      |> get("/api", query: @query)
      |> json_response(400)

    assert %{"errors" => [%{"message" => message}]} = response
    assert message == "Argument \"matching\" has invalid value 123."
  end

  @query """
  {
    menuItems {
      name
    }
  }
  """
  test "orders menu items in ascending order by default" do
    conn = build_conn()
    conn = get(conn, "/api", query: @query)

    assert json_response(conn, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Bánh mì"},
                 %{"name" => "Chocolate Milkshake"},
                 %{"name" => "Croque Monsieur"},
                 %{"name" => "French Fries"},
                 %{"name" => "Lemonade"},
                 %{"name" => "Masala Chai"},
                 %{"name" => "Muffuletta"},
                 %{"name" => "Papadum"},
                 %{"name" => "Pasta Salad"},
                 %{"name" => "Reuben"},
                 %{"name" => "Soft Drink"},
                 %{"name" => "Vada Pav"},
                 %{"name" => "Vanilla Milkshake"},
                 %{"name" => "Water"}
               ]
             }
           }
  end

  @query """
  {
    menuItems(order: DESC) {
      name
    }
  }
  """
  test "menuItems field returns items descending using literals" do
    response = get(build_conn(), "/api", query: @query)

    assert %{
             "data" => %{"menuItems" => [%{"name" => "Water"} | _]}
           } = json_response(response, 200)
  end

  @query """
  {
    menuItems(order: ASC) {
      name
    }
  }
  """
  test "menuItems field returns items ascending using literals" do
    response = get(build_conn(), "/api", query: @query)

    assert %{
             "data" => %{"menuItems" => [%{"name" => "Bánh mì"} | _]}
           } = json_response(response, 200)
  end

  @query """
  query ($order: SortOrder!) {
    menuItems(order: $order) {
      name
    }
  }
  """
  @variables %{"order" => "DESC"}
  test "menuItems field returns items descending using variables" do
    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{
             "data" => %{"menuItems" => [%{"name" => "Water"} | _]}
           } = json_response(response, 200)
  end

  @variables %{"order" => "ASC"}
  test "menuItems field returns items ascending using variables" do
    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{
             "data" => %{"menuItems" => [%{"name" => "Bánh mì"} | _]}
           } = json_response(response, 200)
  end

  defp menu_items_from_response(response) do
    %{"data" => %{"menuItems" => items}} = response

    items
  end
end
