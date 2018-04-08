defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema

  import_types(__MODULE__.MenuTypes)

  query do
    import_fields(:menu_queries)
  end
end
