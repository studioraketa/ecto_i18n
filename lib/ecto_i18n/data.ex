defmodule EctoI18n.Data do
  def translated_table_fk_field(record) do
    :"#{record.__meta__().schema.__i18n__().translated_record_name}_id"
  end

  def translated_schema(record) do
    record.__meta__().schema
  end

  def translated_struct(record) do
    record.__meta__().schema.__struct__
  end

  def translation_schema(record) do
    record.__meta__().schema.__i18n__().schema
  end

  def translation_struct(record) do
    record.__meta__().schema.__i18n__().schema.__struct__
  end

  def fields(record) do
    record.__meta__().schema.__i18n__().fields
  end

  def merge_with_translation(record, translation) do
    translation_map = Map.from_struct(translation)

    Enum.reduce(
      fields(record),
      record,
      fn field, acc ->
        %{acc | field.name => translation_map[field.name]}
      end
    )
  end
end
