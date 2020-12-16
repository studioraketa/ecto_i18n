defmodule EctoI18n.Writer.Creator do
  alias EctoI18n.Data

  import EctoI18n.Writer.Utils

  @repo Application.get_env(:ecto_i18n, :repo)
  @default_locale Application.get_env(:ecto_i18n, :default_locale)

  def run(struct, attrs, @default_locale) do
    struct
    |> Data.translated_schema(struct).changeset(attrs)
    |> @repo.insert()
  end

  def run(struct, attrs, locale) do
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
