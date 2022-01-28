defmodule EctoI18n.CleanerTest do
  use EctoI18n.TestCase

  alias EctoI18n.Cleaner
  alias EctoI18n.Test.{Repo, User}

  defp create_user(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert!()
  end

  defp create_user_translation(user, params) do
    %User.Translation{}
    |> User.Translation.changeset(Map.merge(params, %{user_id: user.id}))
    |> Repo.insert!()
  end

  describe "delete_translation/2" do
    test "deletes a translation for a given locale and record" do
      john =
        create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})

      john_t_es =
        create_user_translation(john, %{
          locale: "es",
          name: "John Doe ES",
          bio: "No me acuerdo..."
        })

      assert {1, _} = Cleaner.delete_translation(john, "es")

      assert_raise Ecto.NoResultsError, fn ->
        Repo.get!(User.Translation, john_t_es.id)
      end
    end

    test "returns a result marking 0 deletions for missing translation" do
      john =
        create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})

      john_t_es =
        create_user_translation(john, %{
          locale: "es",
          name: "John Doe ES",
          bio: "No me acuerdo..."
        })

      assert {0, _} = Cleaner.delete_translation(john, "ru")

      _still_existing_translation = Repo.get!(User.Translation, john_t_es.id)
    end
  end
end
