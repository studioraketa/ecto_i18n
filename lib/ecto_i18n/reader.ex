defmodule EctoI18n.Reader do
  alias __MODULE__.{Bulk, Single}

  def translate(term, locale, opts \\ []) do
    process(term, locale, opts)
  end

  defp process(term, locale, opts) when is_list(term), do: Bulk.translate(term, locale, opts)
  defp process(term, locale, opts), do: Single.translate(term, locale, opts)
end
