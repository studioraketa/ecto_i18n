defmodule EctoI18n.Reader do
  @repo Application.get_env(:ecto_i18n, :repo)
  @default_locale Application.get_env(:ecto_i18n, :default_locale)

  alias EctoI18n.Data
  import Ecto.Query, only: [from: 2]

  def bulk(collection, locale, opts \\ []) do
    bulk_translate(collection, locale, opts)
  end

  defp bulk_translate([], _locale, _opts), do: []
  defp bulk_translate(collection, locale, opts) do
    translated_table_fk_field = translated_table_fk_field(List.first(collection))

    collection
    |> List.first()
    |> translation_schema()
    |> collection_translations(translated_table_fk_field, Enum.map(collection, fn x -> x.id end))
    |> map_translations(translated_table_fk_field)
    |> translate_collection(collection, locale, Keyword.get(opts, :default, @default_locale))
  end

  defp translate_collection(translations_map, collection, locale, default_locale) do
    Enum.map(
      collection,
      fn record ->
        translate_record(Map.get(translations_map, record.id) || [], record, locale, default_locale)
      end
    )
  end

  defp collection_translations(translation_schema, translated_table_fk_field, translated_records_ids) do
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
        {_, updated_map} = Map.get_and_update(
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

  def single(record, locale, opts \\ []) do
    record
    |> translations_for(translation_schema(record), translated_table_fk_field(record))
    |> translate_record(record, locale, Keyword.get(opts, :default, @default_locale))
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

  defp translated_table_fk_field(record) do
    Data.translated_table_fk_field(record)
  end

  defp translation_schema(record) do
    Data.translation_schema(record)
  end

  defp translate_record(_translations, record, @default_locale, _default_locale), do: record

  defp translate_record(translations, record, locale, default_locale) do
    case find_translation(translations, locale, default_locale) do
      nil ->
        record
      translation ->
        Data.merge_with_translation(record, translation)
    end
  end

  defp find_translation(translations, locale, default_locale) do
    pick_translation(
      Enum.find(translations, fn tr -> tr.locale == locale end),
      translations,
      default_locale
    )
  end

  defp pick_translation(nil, _translations, @default_locale), do: nil
  defp pick_translation(nil, translations, default_locale) do
    Enum.find(translations, fn tr -> tr.locale == default_locale end)
  end
  defp pick_translation(translation, _, _), do: translation
end
