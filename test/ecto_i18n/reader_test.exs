defmodule EctoI18n.ReaderTest do
  use EctoI18n.TestCase

  alias EctoI18n.Reader
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

  describe "bulk/3" do
    test "returns translations for given locale and defaults to the original record if default locale is defacult config locale" do
      john = create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})
      john_t_es = create_user_translation(john, %{locale: "es", name: "John Doe ES", bio: "No me acuerdo..."})

      jane = create_user(%{name: "Jane Doe", email: "jane@example.com", bio: "I do not remember..."})

      [translated_john, translated_jane] = Reader.bulk([john, jane], "es")

      assert translated_john.name == john_t_es.name
      assert translated_john.bio == john_t_es.bio

      assert translated_jane.name == jane.name
      assert translated_jane.bio == jane.bio
    end

    test "returns translations for given locale and defaults to the a passed in locale and then to config locale" do
      john = create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})
      john_t_es = create_user_translation(john, %{locale: "es", name: "John Doe ES", bio: "No me acuerdo..."})

      jane = create_user(%{name: "Jane Doe", email: "jane@example.com", bio: "I do not remember..."})
      jane_t_ru = create_user_translation(jane, %{locale: "ru", name: "Jane Doe RU", bio: "спосиба"})

      jake = create_user(%{name: "Jake Doe", email: "jake@example.com", bio: "I do not remember..."})

      [translated_john, translated_jane, translated_jake] =
        Reader.bulk([john, jane, jake], "es", default: "ru")

      assert translated_john.name == john_t_es.name
      assert translated_john.bio == john_t_es.bio

      assert translated_jane.name == jane_t_ru.name
      assert translated_jane.bio == jane_t_ru.bio

      assert translated_jake.name == jake.name
      assert translated_jake.bio == jake.bio
    end
  end

  describe "single/3" do
    test "returns translation for given locale" do
      john = create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})
      john_t_es = create_user_translation(john, %{locale: "es", name: "John Doe ES", bio: "No me acuerdo..."})

      translated_john = Reader.single(john, "es")

      assert translated_john.name == john_t_es.name
      assert translated_john.bio == john_t_es.bio
    end

    test "defaults to config locale (record) if no options default locale is present" do
      john = create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})

      translated_john = Reader.single(john, "es")

      assert translated_john.name == john.name
      assert translated_john.bio == john.bio
    end

    test "defaults to the given in the locale options when it is present" do
      john = create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})
      es_john = create_user_translation(john, %{locale: "es", name: "John Doe ES", bio: "No me acuerdo..."})

      translated_john = Reader.single(john, "en", default: "es")

      assert translated_john.name == es_john.name
      assert translated_john.bio == es_john.bio
    end

    test "returns translation with locale matching the config when the default is overriden in the options" do
      john = create_user(%{name: "Иван Иванов", email: "john@example.com", bio: "Не помня..."})
      en_john = create_user_translation(john, %{locale: "en", name: "John Doe", bio: "I do not remember..."})

      translated_john = Reader.single(john, "en", default: "bg")

      assert translated_john.name == en_john.name
      assert translated_john.bio == en_john.bio
    end

    test "when no translation for given locale exists and default locale not specified defaults to config locale and returns record" do
      john = create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})

      translated_john = Reader.single(john, "es")

      assert translated_john.name == john.name
      assert translated_john.bio == john.bio
    end

    test "defaults to given in the options default locale when there is a translation for it" do
      john = create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})
      john_t_ru = create_user_translation(john, %{locale: "ru", name: "John Doe RU", bio: "спосиба"})

      translated_john = Reader.single(john, "es", default: "ru")

      assert translated_john.name == john_t_ru.name
      assert translated_john.bio == john_t_ru.bio
    end

    test "defaults to config locale and returns original record if no translation for given and given default locales exist" do
      john = create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})

      translated_john = Reader.single(john, "es", default: "ru")

      assert translated_john.name == john.name
      assert translated_john.bio == john.bio
    end
  end
end
