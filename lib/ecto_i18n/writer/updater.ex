defmodule EctoI18n.Writer.Updater do
  alias EctoI18n.Data

  import EctoI18n.Writer.Utils

  @repo Application.get_env(:ecto_i18n, :repo)
  @default_locale Application.get_env(:ecto_i18n, :default_locale)

  def run(record, attrs, locale, opts) do
    # The passed in default locale overrides the config default locale!
    default_locale = Keyword.get(opts, :default, @default_locale)

    case locale == default_locale do
      true ->
        update(record, attrs)
      false ->
        update_with_translation(record, attrs, locale, default_locale)
    end
  end

  defp update(record, attrs) do
    record
    |> Data.translated_schema(record).changeset(attrs)
    |> @repo.update()
  end

  defp update_with_translation(record, attrs, locale, default_locale) do
    translation = find_translation(record, locale)
    record_params = attrs |> atomize_keys() |> extract_record_params(record)

    @repo.transaction(fn ->
      {:ok, updated_record} =
        record
        |> Data.translated_schema(record).changeset(record_params)
        |> @repo.update()
        |> check_result()

      {:ok, relevant_translation} = case translation do
        nil ->
          translation_params = attrs |> atomize_keys() |> extract_translation_create_params(
            record,
            default_locale
          )
          create_translation(record, translation_params, locale)
        translation ->
          translation_params = attrs |> atomize_keys() |> extract_translation_update_params(record)
          update_translation(record, translation, translation_params)
      end

      Data.merge_with_translation(updated_record, relevant_translation)
    end)
  end

  defp find_translation(record, locale) do
    @repo.get_by(
      Data.translation_schema(record),
      [
        {Data.translated_table_fk_field(record), record.id},
        {:locale, locale}
      ]
    )
  end

  defp extract_record_params(params, record) do
    Map.drop(
      params,
      Enum.map(Data.fields(record), fn field -> field.name end)
    )
  end

  defp extract_translation_update_params(params, record) do
    Enum.reduce(
      Data.fields(record),
      %{},
      fn field, acc ->
        case Map.has_key?(params, field.name) do
          true ->
            Map.put(acc, field.name, Map.fetch!(params, field.name))
          _ ->
            acc
        end

      end
    )
  end

  defp extract_translation_create_params(params, record, default_locale) do
    case find_translation(record, default_locale) do
      nil ->
        translation_params_with_defaults(params, record, record)
      translation ->
        translation_params_with_defaults(params, record, translation)
    end
  end

  defp translation_params_with_defaults(params, record, source_struct) do
    defaults_map = Map.from_struct(source_struct)

    Enum.reduce(
      Data.fields(record),
      %{},
      fn field, acc ->
        Map.put(
          acc,
          field.name,
          Map.get(params, field.name) || Map.get(defaults_map, field.name, field.default)
        )
      end
    )
  end
end
