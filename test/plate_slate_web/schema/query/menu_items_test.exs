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
    conn = build_conn()
    conn = get(conn, "/api", query: @query)

    %{"data" => %{"menuItems" => items}} = json_response(conn, 200)

    assert Enum.all?(items, fn item ->
             %{"name" => _, "price" => _} = item
           end) == true
  end
end
