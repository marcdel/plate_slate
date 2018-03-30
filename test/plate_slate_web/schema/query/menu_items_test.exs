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
    menuItems(filter: {name: "reu"}) {
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
    menuItems(filter: {name: $term}) {
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
    menuItems(filter: {name: 123}) {
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

    assert message ==
             "Argument \"filter\" has invalid value {name: 123}.\nIn field \"name\": Expected type \"String\", found 123."
  end

  @query """
  {
    menuItems {
      name
    }
  }
  """
  test "orders menu items in ascending order by default" do
    items =
      build_conn()
      |> get("/api", query: @query, variables: @variables)
      |> json_response(200)
      |> menu_items_from_response()

    assert items == [
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
  end

  @query """
  {
    menuItems(order: DESC) {
      name
    }
  }
  """
  test "menuItems field returns items descending using literals" do
    items =
      build_conn()
      |> get("/api", query: @query, variables: @variables)
      |> json_response(200)
      |> menu_items_from_response()

    assert [%{"name" => "Water"} | _] = items
  end

  @query """
  {
    menuItems(order: ASC) {
      name
    }
  }
  """
  test "menuItems field returns items ascending using literals" do
    items =
      build_conn()
      |> get("/api", query: @query, variables: @variables)
      |> json_response(200)
      |> menu_items_from_response()

    assert [%{"name" => "Bánh mì"} | _] = items
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
    items =
      build_conn()
      |> get("/api", query: @query, variables: @variables)
      |> json_response(200)
      |> menu_items_from_response()

    assert [%{"name" => "Water"} | _] = items
  end

  @variables %{"order" => "ASC"}
  test "menuItems field returns items ascending using variables" do
    items =
      build_conn()
      |> get("/api", query: @query, variables: @variables)
      |> json_response(200)
      |> menu_items_from_response()

    assert [%{"name" => "Bánh mì"} | _] = items
  end

  @query """
  {
    menuItems(filter: {category: "Sandwiches", tag: "Vegetarian"}) {
      name
    }
  }
  """
  test "menuItems field returns menuItems, filtering with a literal" do
    items =
      build_conn()
      |> get("/api", query: @query, variables: @variables)
      |> json_response(200)
      |> menu_items_from_response()

    assert items == [%{"name" => "Vada Pav"}]
  end

  @query """
  query ($filter: MenuItemFilter!) {
    menuItems(filter: $filter) {
      name
    }
  }
  """
  @variables %{filter: %{"tag" => "Vegetarian", "category" => "Sandwiches"}}
  test "menuItems field returns menuItems, filtering with a variable" do
    items =
      build_conn()
      |> get("/api", query: @query, variables: @variables)
      |> json_response(200)
      |> menu_items_from_response()

    assert items == [%{"name" => "Vada Pav"}]
  end

  defp menu_items_from_response(response) do
    %{"data" => %{"menuItems" => items}} = response

    items
  end
end
