defmodule EctoI18n.Test.Migrations.CreateUserTranslations do
  use(
    EctoI18n.Migrations.CreateTable,
    translated_schema: EctoI18n.Test.User,
    fields: [
      %{name: :name, type: :string, null: false, default: ""},
      %{name: :bio, type: :string, null: false, default: ""}
    ]
  )
end
