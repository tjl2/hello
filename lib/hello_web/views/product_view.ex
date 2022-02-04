defmodule HelloWeb.ProductView do
  use HelloWeb, :view

  # Next, let's expose our new feature to the web by adding the category input
  # to our product form. To keep our form template tidy, let's write a new
  # function to wrap up the details of rendering a category select input for our
  # product. We added a new category_select/2 function which uses Phoenix.HTML's
  # multiple_select/3 to generate a multiple select tag. We calculated the
  # existing category IDs from our changeset, then used those values when we
  # generate the select options for the input tag. We did this by enumerating
  # over all of our categories and returning the appropriate key, value, and
  # selected values. We marked an option as selected if the category ID was
  # found in those category IDs in our changeset.
  def category_select(f, changeset) do
    existing_ids =
      changeset
      |> Ecto.Changeset.get_change(:categories, [])
      |> Enum.map(& &1.data.id)

    category_opts =
      for cat <- Hello.Catalog.list_categories(),
          do: [key: cat.title, value: cat.id, selected: cat.id in existing_ids]

    multiple_select(f, :category_ids, category_opts)
  end
end
