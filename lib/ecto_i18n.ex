defmodule EctoI18n do
  alias __MODULE__.{Reader, Writer}

  import __MODULE__.Schema

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @i18n_fields Keyword.fetch!(opts, :fields)
      @i18n_table_name Keyword.fetch!(opts, :translation_table)
      @i18n_record_name Keyword.fetch!(opts, :translation_record)
      @i18n_translated_table_name Keyword.fetch!(opts, :table)
      @i18n_translated_record_name Keyword.fetch!(opts, :record)

      define_translation_schema(__MODULE__, opts)

      def __i18n__ do
        %{
          fields: @i18n_fields,
          table_name: @i18n_table_name,
          record_name: @i18n_record_name,
          schema: __MODULE__.Translation,
          translated_table_name: @i18n_translated_table_name,
          translated_record_name: @i18n_translated_record_name,
        }
      end
    end
  end

  def translate(term, locale, opts) when is_list(term), do: Reader.bulk(term, locale, opts)
  def translate(term, locale, opts), do: Reader.single(term, locale, opts)

  def create(struct, attrs, locale, opts \\ []), do: Writer.create(struct, attrs, locale, opts)
  def update(record, attrs, locale, opts \\ []), do: Writer.update(record, attrs, locale, opts)
end
