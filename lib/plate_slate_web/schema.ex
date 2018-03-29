defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema
  alias PlateSlate.{Repo, Menu}
  alias PlateSlateWeb.Resolvers

  enum :sort_order do
    value(:asc)
    value(:desc)
  end

  query do
    @desc "The list of available items on the menu"
    field(:menu_items, list_of(:menu_item)) do
      @desc "Matches the provided string anywhere in the item name"
      arg(:matching, :string)

      @desc "Sorts items in asc of desc order by item name"
      arg(:order, type: :sort_order, default_value: :asc)

      resolve(&Resolvers.Menu.menu_items/3)
    end
  end

  @desc "An item on the menu"
  object :menu_item do
    @desc "Primary key of the Menu.Items table"
    field(:id, :id)

    @desc "The name of the menu item"
    field(:name, :string)

    @desc "A description of the item"
    field(:description, :string)

    @desc "The decimal price of the item (ex: 4.5)"
    field(:price, :float)
  end
end
