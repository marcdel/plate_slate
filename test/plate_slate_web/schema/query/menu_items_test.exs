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

  defp menu_items_from_response(response) do
    %{"data" => %{"menuItems" => items}} = response

    items
  end
end
