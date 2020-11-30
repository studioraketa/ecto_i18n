defmodule EctoI18n.Schema do
  defmacro define_translation_schema(schema_module, opts) do
    quote do
      defmodule Translation do
        @i18n_opts %{
          fields: Keyword.fetch!(unquote(opts), :fields),
          table_name: Keyword.fetch!(unquote(opts), :translation_table),
          record_name: Keyword.fetch!(unquote(opts), :translation_record),
          translated_table_name: Keyword.fetch!(unquote(opts), :table),
          translated_record_name: Keyword.fetch!(unquote(opts), :record)
        }

        @field_names Enum.map(@i18n_opts.fields, fn x -> x.name end)
        @required_field_names @i18n_opts.fields |> Enum.filter(fn x -> x.required end) |> Enum.map(fn x -> x.name end)

        use Ecto.Schema
        import Ecto.Changeset

        schema "#{@i18n_opts.table_name}" do
          field(:locale, :string)

          for field <- @i18n_opts.fields do
            field(
              field.name,
              field.type,
              default: field.default
            )
          end

          belongs_to(@i18n_opts.translated_record_name, unquote(schema_module), on_replace: :nilify)

          timestamps()
        end

        @doc false
        def changeset(translation, attrs) do
          translation
          |> cast(attrs, [:locale, :"#{@i18n_opts.translated_record_name}_id"] ++ @field_names)
          |> validate_required(
            [:locale, :"#{@i18n_opts.translated_record_name}_id"] ++ @required_field_names
          )
          |> assoc_constraint(@i18n_opts.translated_record_name)
          |> unique_constraint(
            :locale,
            name: :"#{@i18n_opts.table_name}_#{@i18n_opts.translated_record_name}_id_locale_index"
          )
        end
      end
    end
  end
end
