# We created a product_categories table and used the primary_key: false option
# since our join table does not need a primary key. Next we defined our
# :product_id and :category_id foreign key fields, and passed on_delete:
# :delete_all to ensure the database prunes our join table records if a linked
# product or category is deleted. By using a database constraint, we enforce
# data integrity at the database level, rather than relying on ad-hoc and
# error-prone application logic. Next, we created indexes for our foreign keys,
# and a unique index to ensure a product cannot have duplicate categories.
defmodule Hello.Repo.Migrations.CreateProductCategories do
  use Ecto.Migration

  def change do
    create table(:product_categories, primary_key: false) do
      add :product_id, references(:products, on_delete: :delete_all)
      add :category_id, references(:categories, on_delete: :delete_all)
    end

    create index(:product_categories, [:product_id])
    create index(:product_categories, [:category_id])
    create unique_index(:product_categories, [:product_id, :category_id])
  end
end
