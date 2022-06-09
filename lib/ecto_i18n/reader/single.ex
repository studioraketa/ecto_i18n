defmodule EctoI18n.Reader.Single do
  @default_locale Application.get_env(:ecto_i18n, :default_locale)

  alias EctoI18n.Reader.Common

  def translate(record, locale, opts \\ []) do
    Common.translate_record(
      record,
      locale,
      Keyword.get(opts, :default, @default_locale),
      Keyword.get(opts, :associations, [])
    )
  end
end
