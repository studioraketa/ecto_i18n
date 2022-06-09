defmodule EctoI18n.Test.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:title, :string, null: false)
      add(:content, :string, null: false)
    end
  end
end
