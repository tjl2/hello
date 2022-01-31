defmodule Hello.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :title, :string
      add :description, :string
      add :price, :decimal
      add :view, :integer

      timestamps()
    end
  end
end
