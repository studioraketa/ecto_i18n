defmodule EctoI18n.Writer.Creator do
  alias EctoI18n.Data

  import EctoI18n.Writer.Utils

  @repo Application.get_env(:ecto_i18n, :repo)
  @default_locale Application.get_env(:ecto_i18n, :default_locale)

  def run(struct, attrs, locale, opts) do
    # The passed in default locale overrides the config default locale!
    default_locale = Keyword.get(opts, :default, @default_locale)

    case locale == default_locale do
      true ->
        create(struct, attrs)
      false ->
        create_with_translation(struct, attrs, locale)
    end
  end

  def create(struct, attrs) do
    struct
    |> Data.translated_schema(struct).changeset(attrs)
    |> @repo.insert()
  end

  defp create_with_translation(struct, attrs, locale) do
    translation_params = attrs |> atomize_keys() |> extract_translation_params(struct)

    @repo.transaction(fn ->
      {:ok, record} =
        struct
        |> Data.translated_schema(struct).changeset(attrs)
        |> @repo.insert()
        |> check_result()

      {:ok, translation} = create_translation(record, translation_params, locale)

      Data.merge_with_translation(record, translation)
    end)
  end

  defp extract_translation_params(params, record) do
    Enum.reduce(
      Data.fields(record),
      %{},
      fn field, acc ->
        Map.put(acc, field.name, Map.get(params, field.name, field.default))
      end
    )
  end
end
