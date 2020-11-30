defmodule EctoI18n.TranslationWriter do
  alias EctoI18n.Data
  alias Ecto.Changeset

  @repo Application.get_env(:ecto_i18n, :repo)
  @default_locale Application.get_env(:ecto_i18n, :default_locale)

  def create(struct, attrs, @default_locale) do
    struct
    |> Data.translated_schema(struct).changeset(attrs)
    |> @repo.insert()
  end

  def create(struct, attrs, locale) do
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

  def update(record, attrs, locale, opts \\ []), do: do_update(record, attrs, locale, opts)

  defp do_update(record, attrs, @default_locale, _opts) do
    record
    |> Data.translated_schema(record).changeset(attrs)
    |> @repo.update()
  end

  defp do_update(record, attrs, locale, opts) do
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
          translation_params = attrs |> atomize_keys() |> extract_create_params_on_update(
            record,
            Keyword.get(opts, :default, @default_locale)
          )
          create_translation(record, translation_params, locale)
        translation ->
          translation_params = attrs |> atomize_keys() |> extract_translation_params(record)
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

  defp extract_translation_params(params, record) do
    Enum.reduce(
      Data.fields(record),
      %{},
      fn field, acc ->
        Map.put(acc, field.name, Map.get(params, field.name, field.default))
      end
    )
  end

  defp extract_create_params_on_update(params, record, @default_locale) do
    translation_params_with_defaults(params, record, record)
  end

  defp extract_create_params_on_update(params, record, locale) do
    case find_translation(record, locale) do
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

  defp create_translation(record, params, locale) do
    t_params =
      params
      |> Map.put(Data.translated_table_fk_field(record), record.id)
      |> Map.put(:locale, locale)

    Data.translation_struct(record)
    |> Data.translation_schema(record).changeset(t_params)
    |> @repo.insert()
    |> check_translation_result(record)
  end

  defp update_translation(record, translation, params) do
    translation
    |> Data.translation_schema(record).changeset(params)
    |> @repo.update()
    |> check_translation_result(record)
  end

  defp atomize_keys(map) do
    Enum.reduce(map, %{}, fn {k, v}, acc -> Map.put(acc, atomize_key(k), v) end)
  end

  defp atomize_key(key) when is_binary(key), do: String.to_atom(key)
  defp atomize_key(key) when is_atom(key), do: key

  defp check_result({:ok, value}), do: {:ok, value}
  defp check_result({:error, changeset_or_value}), do: @repo.rollback(changeset_or_value)

  defp check_translation_result({:ok, value}, _record), do: {:ok, value}
  defp check_translation_result({:error, changeset}, record) do
    changeset.errors
    |> Enum.reduce(
      Changeset.change(record),
      fn {key, {message, opts}}, cs->
        Changeset.add_error(cs, key, message, opts)
      end
    )
    |> @repo.rollback()
  end
end
