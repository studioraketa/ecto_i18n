defmodule EctoI18n.Writer do
  alias EctoI18n.Writer.{Creator, Updater}

  def create(struct, attrs, locale), do: Creator.run(struct, attrs, locale)

  def update(record, attrs, locale, opts \\ []), do: Updater.run(record, attrs, locale, opts)
end
