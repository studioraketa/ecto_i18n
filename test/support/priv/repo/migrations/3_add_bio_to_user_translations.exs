defmodule EctoI18n.Test.Migrations.AddBioToUserTranslations do
  use(
    EctoI18n.Migrations.AddColumns,
    translated_schema: EctoI18n.Test.User,
    fields: [
      %{name: :bio, type: :string, null: false, default: ""},
    ]
  )
end
