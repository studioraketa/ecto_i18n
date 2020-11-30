defmodule EctoI18n.Test.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :bio, :text, null: false, default: ""
    end
  end
end
