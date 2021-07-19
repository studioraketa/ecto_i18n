defmodule EctoI18n.WriterTest do
  use EctoI18n.TestCase

  alias EctoI18n.Writer
  alias EctoI18n.Test.{Repo, User}

  @default_locale Application.get_env(:ecto_i18n, :default_locale)

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

  describe "create/3" do
    test "creates a record and no translation for default locale and valid params" do
      params = %{
        name: "John Doe",
        email: "john@example.com",
        bio: "I do not remember..."
      }

      assert {:ok, %User{} = user} = Writer.create(%User{}, params, @default_locale)
      assert user.name == params.name
      assert user.email == params.email
      assert user.bio == params.bio

      refute Repo.get_by(User.Translation, user_id: user.id, locale: @default_locale)
    end

    test "creates a record and no translation for overriden default locale and valid params" do
      params = %{
        name: "John Doe",
        email: "john@example.com",
        bio: "I do not remember..."
      }

      assert {:ok, %User{} = user} = Writer.create(%User{}, params, "ru", default: "ru")
      assert user.name == params.name
      assert user.email == params.email
      assert user.bio == params.bio

      refute Repo.get_by(User.Translation, user_id: user.id, locale: "ru")
    end

    test "returns a changeset with errors for default locale and invalid params" do
      params = %{
        name: "",
        email: "",
        bio: ""
      }

      assert {:error, changeset} = Writer.create(%User{}, params, @default_locale)
      assert "can't be blank" in errors_on(changeset).name
      assert "can't be blank" in errors_on(changeset).email
    end

    test "returns a changeset with errors for overriden default locale and invalid params" do
      params = %{
        name: "",
        email: "",
        bio: ""
      }

      assert {:error, changeset} = Writer.create(%User{}, params, "ru", default: "ru")
      assert "can't be blank" in errors_on(changeset).name
      assert "can't be blank" in errors_on(changeset).email
    end

    test "creates a record and translation for non default locale and valid params" do
      params = %{
        name: "John Doe",
        email: "john@example.com",
        bio: "I do not remember..."
      }

      assert {:ok, %User{} = user} = Writer.create(%User{}, params, "es")
      assert user.name == params.name
      assert user.email == params.email
      assert user.bio == params.bio

      translation = Repo.get_by!(User.Translation, user_id: user.id, locale: "es")
      assert translation.name == params.name
      assert translation.bio == params.bio
    end

    test "returns changeset with errors for non default locale and invalid params for translated record" do
      params = %{
        name: "",
        email: "",
        bio: ""
      }

      assert {:error, changeset} = Writer.create(%User{}, params, "es")
      assert "can't be blank" in errors_on(changeset).name
      assert "can't be blank" in errors_on(changeset).email
    end

    test "returns changeset with errors for non default locale and invalid params for translation" do
      params = %{
        name: "John Doe",
        email: "john@example.com",
        bio: ""
      }

      assert {:error, changeset} = Writer.create(%User{}, params, "es")
      assert "can't be blank" in errors_on(changeset).bio
    end
  end

  describe "update/3" do
    test "updates record for default locale and valid params" do
      user = create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})
      params = %{
        name: "Jack Bouer",
        email: "jack.b@bleble.com",
        bio: "24"
      }

      assert {:ok, %User{} = updated_user} = Writer.update(user, params, @default_locale)
      assert updated_user.name == params.name
      assert updated_user.email == params.email
      assert updated_user.bio == params.bio

      refute Repo.get_by(User.Translation, user_id: updated_user.id, locale: @default_locale)
    end

    test "updates record for overriden default locale and valid params" do
      user = create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})
      params = %{
        name: "Jack Bouer",
        email: "jack.b@bleble.com",
        bio: "24"
      }

      assert {:ok, %User{} = updated_user} = Writer.update(user, params, "ru", default: "ru")
      assert updated_user.name == params.name
      assert updated_user.email == params.email
      assert updated_user.bio == params.bio

      refute Repo.get_by(User.Translation, user_id: updated_user.id, locale: @default_locale)
    end

    test "returns a changeset with errors for default locale and invalid params" do
      user = create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})
      params = %{
        name: "",
        email: "",
        bio: ""
      }

      assert {:error, changeset} = Writer.update(user, params, @default_locale)
      assert "can't be blank" in errors_on(changeset).name
      assert "can't be blank" in errors_on(changeset).email
    end

    test "returns a changeset with errors for overriden default locale and invalid params" do
      user = create_user(%{name: "John Doe", email: "john@example.com", bio: "I do not remember..."})
      params = %{
        name: "",
        email: "",
        bio: ""
      }

      assert {:error, changeset} = Writer.update(user, params, "ru", default: "ru")
      assert "can't be blank" in errors_on(changeset).name
      assert "can't be blank" in errors_on(changeset).email
    end

    test "updates a record and translation for non default locale, valid params and existing translation" do
      user = create_user(%{name: "John Smith", email: "john.smith@example.com", bio: "Some stuff"})
      translation = create_user_translation(user, %{
        locale: "es", name: "John Doe ES", bio: "No me acuerdo..."
      })

      params = %{
        name: "John Smith ES",
        email: "j.smith@example.com",
        bio: "Some stuff in ES"
      }

      assert {:ok, %User{} = updated_user} = Writer.update(user, params, "es")
      assert updated_user.email == params.email
      assert updated_user.name == params.name
      assert updated_user.bio == params.bio

      db_user = Repo.get_by!(User, id: user.id)
      assert db_user.email == params.email
      assert db_user.name == user.name
      assert db_user.bio == user.bio

      updated_translation = Repo.get_by!(User.Translation, user_id: user.id, locale: "es")
      assert updated_translation.id == translation.id
      assert updated_translation.name == params.name
      assert updated_translation.bio == params.bio
    end

    test "updates a record and translation for non default locale, valid partial params and existing translation" do
      user = create_user(%{name: "John Smith", email: "john.smith@example.com", bio: "Some stuff"})
      translation = create_user_translation(user, %{
        locale: "es", name: "John Doe ES", bio: "No me acuerdo..."
      })

      params = %{
        email: "j.smith@example.com",
        bio: "Updated spanish bio"
      }

      assert {:ok, %User{} = updated_user} = Writer.update(user, params, "es")
      assert updated_user.email == params.email
      assert updated_user.name == translation.name
      assert updated_user.bio == params.bio

      db_user = Repo.get_by!(User, id: user.id)
      assert db_user.email == params.email
      assert db_user.name == user.name
      assert db_user.bio == user.bio

      updated_translation = Repo.get_by!(User.Translation, user_id: user.id, locale: "es")
      assert updated_translation.id == translation.id
      assert updated_translation.name == translation.name
      assert updated_translation.bio == params.bio
    end

    test "returns changeset with errors for non default locale, invalid record params and existing translation" do
      user = create_user(%{name: "John Smith", email: "john.smith@example.com", bio: "Some stuff"})
      _translation = create_user_translation(user, %{
        locale: "es", name: "John Doe ES", bio: "No me acuerdo..."
      })

      params = %{
        name: "John Smith ES",
        email: "",
        bio: "Some stuff in ES"
      }

      assert {:error, changeset} = Writer.update(user, params, "es")
      assert "can't be blank" in errors_on(changeset).email
    end

    test "returns changeset with errors for non default locale, invalid translation params and existing translation" do
      user = create_user(%{name: "John Smith", email: "john.smith@example.com", bio: "Some stuff"})
      _translation = create_user_translation(user, %{
        locale: "es", name: "John Doe ES", bio: "No me acuerdo..."
      })

      params = %{
        name: "John Smith ES",
        bio: ""
      }

      assert {:error, changeset} = Writer.update(user, params, "es")
      assert "can't be blank" in errors_on(changeset).bio
    end

    test "updates a record and translation for non default locale, valid params and non existing translation" do
      user = create_user(%{name: "John Smith", email: "john.smith@example.com", bio: "Some stuff"})

      params = %{
        name: "John Smith ES",
        email: "j.smith@example.com",
        bio: "Some stuff in ES"
      }

      assert {:ok, %User{} = updated_user} = Writer.update(user, params, "es")
      assert updated_user.email == params.email
      assert updated_user.name == params.name
      assert updated_user.bio == params.bio

      db_user = Repo.get_by!(User, id: user.id)
      assert db_user.email == params.email
      assert db_user.name == user.name
      assert db_user.bio == user.bio

      translation = Repo.get_by!(User.Translation, user_id: user.id, locale: "es")
      assert translation.name == params.name
      assert translation.bio == params.bio
    end

    test "updates a record and translation for overriden non default locale, valid params and non existing translation" do
      user = create_user(%{name: "John Smith", email: "john.smith@example.com", bio: "Some stuff"})

      params = %{
        name: "John Smith ES",
        email: "j.smith@example.com",
        bio: "Some stuff in ES"
      }

      assert {:ok, %User{} = updated_user} = Writer.update(user, params, @default_locale, default: "ru")
      assert updated_user.email == params.email
      assert updated_user.name == params.name
      assert updated_user.bio == params.bio

      db_user = Repo.get_by!(User, id: user.id)
      assert db_user.email == params.email
      assert db_user.name == user.name
      assert db_user.bio == user.bio

      translation = Repo.get_by!(User.Translation, user_id: user.id, locale: @default_locale)
      assert translation.name == params.name
      assert translation.bio == params.bio
    end

    test "updates a record and translation for non default locale, partial params and non existing translation" do
      user = create_user(%{name: "John Smith", email: "john.smith@example.com", bio: "Some stuff"})

      params = %{
        email: "j.smith@example.com",
        bio: "Some stuff in ES"
      }

      assert {:ok, %User{} = updated_user} = Writer.update(user, params, "es")
      assert updated_user.email == params.email
      assert updated_user.name == user.name
      assert updated_user.bio == params.bio

      db_user = Repo.get_by!(User, id: user.id)
      assert db_user.email == params.email
      assert db_user.name == user.name
      assert db_user.bio == user.bio

      translation = Repo.get_by!(User.Translation, user_id: user.id, locale: "es")
      assert translation.name == user.name
      assert translation.bio == params.bio
    end

    test "updates a record and translation for non default locale, partial params and existing different default" do
      user = create_user(%{name: "John Smith", email: "john.smith@example.com", bio: "Some stuff"})
      ru_translation = create_user_translation(user, %{
        locale: "ru", name: "Комрад Иван Иванов", bio: "Я не знаю.."
      })

      params = %{
        email: "j.smith@example.com",
        bio: "Some stuff in ES"
      }

      assert {:ok, %User{} = updated_user} = Writer.update(user, params, "es", default: "ru")
      assert updated_user.email == params.email
      assert updated_user.name == ru_translation.name
      assert updated_user.bio == params.bio

      db_user = Repo.get_by!(User, id: user.id)
      assert db_user.email == params.email
      assert db_user.name == user.name
      assert db_user.bio == user.bio

      translation = Repo.get_by!(User.Translation, user_id: user.id, locale: "es")
      assert translation.name == ru_translation.name
      assert translation.bio == params.bio
    end

    test "updates a record and translation for non default locale, partial params and non existing different default" do
      user = create_user(%{name: "John Smith", email: "john.smith@example.com", bio: "Some stuff"})

      params = %{
        email: "j.smith@example.com",
        bio: "Some stuff in ES"
      }

      assert {:ok, %User{} = updated_user} = Writer.update(user, params, "es", default: "ru")
      assert updated_user.email == params.email
      assert updated_user.name == user.name
      assert updated_user.bio == params.bio

      db_user = Repo.get_by!(User, id: user.id)
      assert db_user.email == params.email
      assert db_user.name == user.name
      assert db_user.bio == user.bio

      translation = Repo.get_by!(User.Translation, user_id: user.id, locale: "es")
      assert translation.name == user.name
      assert translation.bio == params.bio
    end

    test "returns changeset with errors for non default locale, invalid record params and non existing translation" do
      user = create_user(%{name: "John Smith", email: "john.smith@example.com", bio: "Some stuff"})

      params = %{
        name: "John Smith ES",
        email: "",
        bio: "Some stuff in ES"
      }

      assert {:error, changeset} = Writer.update(user, params, "es")
      assert "can't be blank" in errors_on(changeset).email
    end

    test "returns changeset with errors for non default locale, invalid translation params and non existing translation" do
      user = create_user(%{name: "John Smith", email: "john.smith@example.com", bio: "Some stuff"})

      params = %{
        name: "John Smith ES",
        bio: ""
      }

      assert {:error, changeset} = Writer.update(user, params, "es")
      assert "can't be blank" in errors_on(changeset).bio
    end
  end
end
