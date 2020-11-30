defmodule EctoI18n.Migrations.CreateTable do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @i18n Keyword.fetch!(opts, :translated_schema).__i18n__()
      @fields Keyword.fetch!(opts, :fields)

      use Ecto.Migration

      def change do
        create table(@i18n.table_name) do
          add(
            unquote(:"#{@i18n.translated_record_name}_id"),
            references(@i18n.translated_table_name, on_delete: :delete_all),
            null: false
          )

          add(:locale, :string, null: false, limit: 2)

          for field <- @fields do
            add(
              field.name,
              field.type,
              null: field.null,
              default: field.default
            )
          end

          timestamps()
        end

        create(unique_index(@i18n.table_name, [unquote(:"#{@i18n.translated_record_name}_id"), :locale]))
      end
    end
  end
end
