defmodule EctoI18n.Writer.Utils do
  alias Ecto.Changeset

  alias EctoI18n.Data

  @repo Application.get_env(:ecto_i18n, :repo)

  def atomize_keys(map) do
    Enum.reduce(map, %{}, fn {k, v}, acc -> Map.put(acc, atomize_key(k), v) end)
  end

  defp atomize_key(key) when is_binary(key), do: String.to_atom(key)
  defp atomize_key(key) when is_atom(key), do: key

  def check_result({:ok, value}), do: {:ok, value}
  def check_result({:error, changeset_or_value}), do: @repo.rollback(changeset_or_value)

  def check_translation_result({:ok, value}, _record), do: {:ok, value}
  def check_translation_result({:error, changeset}, record) do
    changeset.errors
    |> Enum.reduce(
      Changeset.change(record),
      fn {key, {message, opts}}, cs->
        Changeset.add_error(cs, key, message, opts)
      end
    )
    |> @repo.rollback()
  end

  def create_translation(record, params, locale) do
    t_params =
      params
      |> Map.put(Data.translated_table_fk_field(record), record.id)
      |> Map.put(:locale, locale)

    Data.translation_struct(record)
    |> Data.translation_schema(record).changeset(t_params)
    |> @repo.insert()
    |> check_translation_result(record)
  end

  def update_translation(record, translation, params) do
    translation
    |> Data.translation_schema(record).changeset(params)
    |> @repo.update()
    |> check_translation_result(record)
  end
end
