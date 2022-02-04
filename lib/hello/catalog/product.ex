defmodule Hello.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hello.Catalog.Category

  schema "products" do
    field :description, :string
    field :price, :decimal
    field :title, :string
    field :views, :integer

    # We use Ecto.Schema's many_to_many macro to let Ecto know how to associate
    # our product to multiple categories through the "product_categories" join
    # table. We also use the on_replace: :delete option to declare that any
    # existing join records should be deleted when we are changing our
    # categories.
    many_to_many :categories, Category, join_through: "product_categories", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:title, :description, :price, :views])
    |> validate_required([:title, :description, :price, :views])
  end
end
