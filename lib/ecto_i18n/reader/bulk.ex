defmodule EctoI18n.Reader.Bulk do
  @default_locale Application.get_env(:ecto_i18n, :default_locale)

  alias EctoI18n.Reader.Common

  def translate(collection, locale, opts \\ []) do
    bulk_translate(collection, locale, opts)
  end

  defp bulk_translate([], _locale, _opts), do: []

  defp bulk_translate(collection, locale, opts) do
    translate_collection(
      collection,
      locale,
      Keyword.get(opts, :default, @default_locale),
      Keyword.get(opts, :associations, [])
    )
  end

  defp translate_collection(collection, locale, default_locale, associations) do
    Enum.map(
      collection,
      fn record ->
        Common.translate_record(
          record,
          locale,
          default_locale,
          associations
        )
      end
    )
  end
end
