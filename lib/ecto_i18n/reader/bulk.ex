defmodule EctoI18n.Reader.Bulk do
  @repo Application.get_env(:ecto_i18n, :repo)
  @default_locale Application.get_env(:ecto_i18n, :default_locale)

  alias EctoI18n.Reader.Common

  import Ecto.Query, only: [from: 2]

  def translate(collection, locale, opts \\ []) do
    bulk_translate(collection, locale, opts)
  end

  defp bulk_translate([], _locale, _opts), do: []

  defp bulk_translate(collection, locale, opts) do
    translated_table_fk_field = Common.translated_table_fk_field(List.first(collection))

    collection
    |> List.first()
    |> Common.translation_schema()
    |> collection_translations(translated_table_fk_field, Enum.map(collection, fn x -> x.id end))
    |> map_translations(translated_table_fk_field)
    |> translate_collection(collection, locale, Keyword.get(opts, :default, @default_locale))
  end

  defp translate_collection(translations_map, collection, locale, default_locale) do
    Enum.map(
      collection,
      fn record ->
        Common.translate_record(
          Map.get(translations_map, record.id) || [],
          record,
          locale,
          default_locale
        )
      end
    )
  end

  defp collection_translations(
         translation_schema,
         translated_table_fk_field,
         translated_records_ids
       ) do
    @repo.all(
      from(
        i18n in translation_schema,
        where: field(i18n, ^translated_table_fk_field) in ^translated_records_ids,
        select: i18n
      )
    )
  end

  defp map_translations(translations, translated_table_fk_field) do
    Enum.reduce(
      translations,
      %{},
      fn trans, acc ->
        {_, updated_map} =
          Map.get_and_update(
            acc,
            Map.from_struct(trans)[translated_table_fk_field],
            fn
              nil ->
                {nil, [trans]}

              current_value ->
                {current_value, [trans | current_value]}
            end
          )

        updated_map
      end
    )
  end
end
