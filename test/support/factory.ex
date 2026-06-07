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
    unique_id = System.unique_integer([:positive])

    user_info = %{
      "email_verified" => Enum.random([true, false]),
      "email" => "user-#{unique_id}@example.com",
      "name" => "User #{unique_id}",
      "sub" => "google-oauth2|#{unique_id}",
      "picture" => "https://example.com/users/#{unique_id}.png"
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
    unique_id = System.unique_integer([:positive])

    Thread.create!(
      %{
        name: "Thread #{unique_id}",
        mediator_notes: "Mediator notes #{unique_id}"
      },
      actor: user
    )
  end
end
