defmodule EctoI18n.Test.User do
  use Ecto.Schema
  import Ecto.Changeset

  use(
    EctoI18n,
    translation_table: :user_translations,
    translation_record: :user_translation,
    table: :users,
    record: :user,
    fields: [
      %{name: :name, type: :string, default: "", required: true},
      %{name: :bio, type: :string, default: "", required: true}
    ]
  )

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:bio, :string, default: "")
  end

  def changeset(user, attributes) do
    user
    |> cast(attributes, [:name, :email, :bio])
    |> validate_required([:name, :email])
  end
end
