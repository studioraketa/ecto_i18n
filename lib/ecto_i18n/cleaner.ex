defmodule EctoI18n.Cleaner do
  @repo Application.get_env(:ecto_i18n, :repo)

  alias EctoI18n.Data
  import Ecto.Query, only: [from: 2]

  def delete_translation(record, locale) do
    @repo.delete_all(
      from(
        i18n in Data.translation_schema(record),
        where:
          field(i18n, ^Data.translated_table_fk_field(record)) == ^record.id and
            i18n.locale == ^locale,
        select: i18n
      )
    )
  end
end
