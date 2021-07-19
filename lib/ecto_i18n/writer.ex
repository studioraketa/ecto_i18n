defmodule EctoI18n.Writer do
  alias EctoI18n.Writer.{Creator, Updater}

  def create(struct, attrs, locale, opts \\ []), do: Creator.run(struct, attrs, locale, opts)

  def update(record, attrs, locale, opts \\ []), do: Updater.run(record, attrs, locale, opts)
end
