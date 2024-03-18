defmodule EctoI18n.ReaderTest do
  use EctoI18n.TestCase

  alias EctoI18n.Reader
  alias EctoI18n.Test.{Post, Repo, User}

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

  defp create_post(params) do
    %Post{}
    |> Post.changeset(params)
    |> Repo.insert!()
  end

  defp create_post_translation(post, params) do
    %Post.Translation{}
    |> Post.Translation.changeset(Map.merge(params, %{post_id: post.id}))
    |> Repo.insert!()
  end

  describe "translate/3 for collection" do
    test "returns translations for given locale and defaults to the original record if default locale is default config locale" do
      john =
        create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})

      john_t_es =
        create_user_translation(john, %{
          locale: "es",
          name: "John Doe ES",
          bio: "No me acuerdo..."
        })

      jane =
        create_user(%{name: "Jane Doe", email: "jane@example.com", bio: "I do not remember..."})

      john = Repo.preload(john, :translations)
      jane = Repo.preload(jane, :translations)

      [translated_john, translated_jane] = Reader.translate([john, jane], "es")

      assert translated_john.name == john_t_es.name
      assert translated_john.bio == john_t_es.bio

      assert translated_jane.name == jane.name
      assert translated_jane.bio == jane.bio
    end

    test "returns translations for given locale and defaults to the a passed in locale and then to config locale" do
      john =
        create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})

      john_t_es =
        create_user_translation(john, %{
          locale: "es",
          name: "John Doe ES",
          bio: "No me acuerdo..."
        })

      jane =
        create_user(%{name: "Jane Doe", email: "jane@example.com", bio: "I do not remember..."})

      jane_t_ru =
        create_user_translation(jane, %{locale: "ru", name: "Jane Doe RU", bio: "спосиба"})

      jake =
        create_user(%{name: "Jake Doe", email: "jake@example.com", bio: "I do not remember..."})

      john = Repo.preload(john, :translations)
      jane = Repo.preload(jane, :translations)
      jake = Repo.preload(jake, :translations)

      [translated_john, translated_jane, translated_jake] =
        Reader.translate([john, jane, jake], "es", default: "ru")

      assert translated_john.name == john_t_es.name
      assert translated_john.bio == john_t_es.bio

      assert translated_jane.name == jane_t_ru.name
      assert translated_jane.bio == jane_t_ru.bio

      assert translated_jake.name == jake.name
      assert translated_jake.bio == jake.bio
    end

    test "returns translations of the records as well as the described associations" do
      john =
        create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})

      john_t_es =
        create_user_translation(john, %{
          locale: "es",
          name: "John Doe ES",
          bio: "No me acuerdo..."
        })

      post = create_post(%{title: "Title", content: "Content", user_id: john.id})

      post_t_es =
        create_post_translation(post, %{locale: "es", title: "Title ES", content: "Content ES"})

      john = Repo.preload(john, [:translations, :posts, posts: :translations])

      [translated_john] = Reader.translate([john], "es", associations: [:posts])

      assert translated_john.name == john_t_es.name
      assert translated_john.bio == john_t_es.bio

      [translated_post] = translated_john.posts

      assert translated_post.title == post_t_es.title
      assert translated_post.content == post_t_es.content
    end
  end

  describe "translate/3 for a single record" do
    test "returns translation for given locale" do
      john =
        create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})

      john_t_es =
        create_user_translation(john, %{
          locale: "es",
          name: "John Doe ES",
          bio: "No me acuerdo..."
        })

      john = Repo.preload(john, :translations)

      translated_john = Reader.translate(john, "es")

      assert translated_john.name == john_t_es.name
      assert translated_john.bio == john_t_es.bio
    end

    test "defaults to config locale (record) if no options default locale is present" do
      john =
        create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})

      john = Repo.preload(john, :translations)

      translated_john = Reader.translate(john, "es")

      assert translated_john.name == john.name
      assert translated_john.bio == john.bio
    end

    test "defaults to the given in the locale options when it is present" do
      john =
        create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})

      es_john =
        create_user_translation(john, %{
          locale: "es",
          name: "John Doe ES",
          bio: "No me acuerdo..."
        })

      john = Repo.preload(john, :translations)

      translated_john = Reader.translate(john, "en", default: "es")

      assert translated_john.name == es_john.name
      assert translated_john.bio == es_john.bio
    end

    test "returns translation with locale matching the config when the default is overriden in the options" do
      john = create_user(%{name: "Иван Иванов", email: "john@example.com", bio: "Не помня..."})

      en_john =
        create_user_translation(john, %{
          locale: "en",
          name: "John Doe",
          bio: "I do not remember..."
        })

      john = Repo.preload(john, :translations)

      translated_john = Reader.translate(john, "en", default: "bg")

      assert translated_john.name == en_john.name
      assert translated_john.bio == en_john.bio
    end

    test "when no translation for given locale exists and default locale not specified defaults to config locale and returns record" do
      john =
        create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})

      john = Repo.preload(john, :translations)

      translated_john = Reader.translate(john, "es")

      assert translated_john.name == john.name
      assert translated_john.bio == john.bio
    end

    test "defaults to given in the options default locale when there is a translation for it" do
      john =
        create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})

      john_t_ru =
        create_user_translation(john, %{locale: "ru", name: "John Doe RU", bio: "спосиба"})

      john = Repo.preload(john, :translations)

      translated_john = Reader.translate(john, "es", default: "ru")

      assert translated_john.name == john_t_ru.name
      assert translated_john.bio == john_t_ru.bio
    end

    test "defaults to config locale and returns original record if no translation for given and given default locales exist" do
      john =
        create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})

      john = Repo.preload(john, :translations)

      translated_john = Reader.translate(john, "es", default: "ru")

      assert translated_john.name == john.name
      assert translated_john.bio == john.bio
    end

    test "returns translations of the record as well as the described associations" do
      john =
        create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})

      john_t_es =
        create_user_translation(john, %{
          locale: "es",
          name: "John Doe ES",
          bio: "No me acuerdo..."
        })

      post = create_post(%{title: "Title", content: "Content", user_id: john.id})

      post_t_es =
        create_post_translation(post, %{locale: "es", title: "Title ES", content: "Content ES"})

      john = Repo.preload(john, [:translations, :posts, posts: :translations])

      translated_john = Reader.translate(john, "es", associations: [:posts])

      assert translated_john.name == john_t_es.name
      assert translated_john.bio == john_t_es.bio

      [translated_post] = translated_john.posts

      assert translated_post.title == post_t_es.title
      assert translated_post.content == post_t_es.content
    end
  end
end
