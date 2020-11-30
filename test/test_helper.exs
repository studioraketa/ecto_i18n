defmodule EctoI18n.TestCase do
  use ExUnit.CaseTemplate

  using opts do
    quote do
      use ExUnit.Case, unquote(opts)
      import Ecto.Query

      @doc """
      A helper that transforms changeset errors into a map of messages.

          assert {:error, changeset} = Accounts.create_user(%{password: "short"})
          assert "password is too short" in errors_on(changeset).password
          assert %{password: ["password is too short"]} = errors_on(changeset)

      """
      def errors_on(changeset) do
        Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
          Regex.replace(~r"%{(\w+)}", message, fn _, key ->
            opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
          end)
        end)
      end
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EctoI18n.Test.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(EctoI18n.Test.Repo, {:shared, self()})
    :ok
  end
end

EctoI18n.Test.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(EctoI18n.Test.Repo, :manual)

ExUnit.start()
