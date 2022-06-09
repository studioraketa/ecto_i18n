defmodule EctoI18n.Test.Post do
  use Ecto.Schema
  import Ecto.Changeset

  use(
    EctoI18n,
    translation_table: :post_translations,
    translation_record: :post_translation,
    table: :posts,
    record: :post,
    fields: [
      %{name: :title, type: :string, default: "", required: true},
      %{name: :content, type: :string, default: "", required: true}
    ]
  )

  schema "posts" do
    field(:title, :string)
    field(:content, :string)

    belongs_to(:user, EctoI18n.Test.User)
    has_many(:translations, __MODULE__.Translation)
  end

  def changeset(post, attributes) do
    post
    |> cast(attributes, [:title, :content, :user_id])
    |> validate_required([:title, :content, :user_id])
    |> assoc_constraint(:user)
  end
end
