defmodule EctoI18n.Test.Migrations.RemoveBioFromUserTranslations do
  use(
    EctoI18n.Migrations.RemoveColumns,
    translated_schema: EctoI18n.Test.User,
    fields: [
      %{name: :bio, type: :string, null: false, default: ""},
    ]
  )
end
