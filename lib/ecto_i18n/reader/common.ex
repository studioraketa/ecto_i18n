defmodule EctoI18n.Reader.Common do
  @default_locale Application.get_env(:ecto_i18n, :default_locale)

  alias EctoI18n.Data

  def translate_record(record, @default_locale, @default_locale, _associations),
    do: record

  def translate_record(record, locale, default_locale, associations) do
    translated_record = translate(record, locale, default_locale)

    Enum.reduce(associations, translated_record, fn association_key, tr_record ->
      case Map.get(record, association_key) do
        nil ->
          tr_record

        association_value ->
          Map.put(
            tr_record,
            association_key,
            translate_association(association_value, locale, default_locale)
          )
      end
    end)
  end

  defp translate_association(associations, locale, default_locale) when is_list(associations) do
    Enum.map(associations, fn x -> translate(x, locale, default_locale) end)
  end

  defp translate_association(association, locale, default_locale) do
    translate(association, locale, default_locale)
  end

  defp translate(record, locale, default_locale) do
    case find_translation(record.translations, locale, default_locale) do
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
