defmodule Mediate.Factory do
  alias Mediate.Accounts.User
  alias Mediate.Chat.Thread

  def admin_user do
    user_info = %{
      "email_verified" => true,
      "email" => "dewetblomerus@gmail.com",
      "name" => "De Wet",
      "sub" => "google-oauth2|redacted",
      "picture" => "https://picture-url.com"
    }

    User
    |> Ash.Changeset.for_action(
      :register_with_auth0,
      %{
        user_info: user_info,
        oauth_tokens: %{}
      }
    )
    |> Ash.create!()
  end

  def user_factory do
    user_info = %{
      "email_verified" => Enum.random([true, false]),
      "email" => Faker.Internet.email(),
      "name" => Faker.Person.name(),
      "sub" => "google-oauth2|#{System.unique_integer([:positive])}",
      "picture" => Faker.Internet.url()
    }

    User
    |> Ash.Changeset.for_action(
      :register_with_auth0,
      %{
        user_info: user_info,
        oauth_tokens: %{}
      }
    )
    |> Ash.create!()
  end

  def thread_factory(user, _) do
    Thread.create!(
      %{
        name: Faker.String.base64(40),
        mediator_notes: Faker.String.base64()
      },
      actor: user
    )
  end
end
