defmodule EctoI18n.Test.Migrations.CreatePostTranslations do
  use(
    EctoI18n.Migrations.CreateTable,
    translated_schema: EctoI18n.Test.Post,
    fields: [
      %{name: :title, type: :string, null: false, default: ""},
      %{name: :content, type: :string, null: false, default: ""}
    ]
  )
end
