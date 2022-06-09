defmodule EctoI18n.Reader.Common do
  @default_locale Application.get_env(:ecto_i18n, :default_locale)

  alias EctoI18n.Data

  def translated_table_fk_field(record) do
    Data.translated_table_fk_field(record)
  end

  def translation_schema(record) do
    Data.translation_schema(record)
  end

  def translate_record(_translations, record, @default_locale, @default_locale), do: record

  def translate_record(translations, record, locale, default_locale) do
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
