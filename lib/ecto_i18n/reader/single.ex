defmodule EctoI18n.Reader.Single do
  @repo Application.get_env(:ecto_i18n, :repo)
  @default_locale Application.get_env(:ecto_i18n, :default_locale)

  alias EctoI18n.Reader.Common

  import Ecto.Query, only: [from: 2]

  def translate(record, locale, opts \\ []) do
    record
    |> translations_for(
      Common.translation_schema(record),
      Common.translated_table_fk_field(record)
    )
    |> Common.translate_record(record, locale, Keyword.get(opts, :default, @default_locale))
  end

  defp translations_for(record, translation_schema, translated_table_fk_field) do
    @repo.all(
      from(
        i18n in translation_schema,
        where: field(i18n, ^translated_table_fk_field) == ^record.id,
        select: i18n
      )
    )
  end
end
