defmodule EctoI18n.Migrations.RemoveColumns do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @i18n Keyword.fetch!(opts, :translated_schema).__i18n__()
      @fields Keyword.fetch!(opts, :fields)

      use Ecto.Migration

      def change do
        alter table(@i18n.table_name) do
          for field <- @fields do
            remove(
              field.name,
              field.type,
              null: field.null,
              default: field.default
            )
          end
        end
      end
    end
  end
end
