defmodule Mediate.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :strategies, :auth0, :client_id],
        Mediate.Accounts.User,
        _
      ) do
    get_config(:client_id)
  end

  def secret_for(
        [:authentication, :strategies, :auth0, :redirect_uri],
        Mediate.Accounts.User,
        _
      ) do
    get_config(:redirect_uri)
  end

  def secret_for(
        [:authentication, :strategies, :auth0, :client_secret],
        Mediate.Accounts.User,
        _
      ) do
    get_config(:client_secret)
  end

  def secret_for(
        [:authentication, :strategies, :auth0, :base_url],
        Mediate.Accounts.User,
        _
      ) do
    get_config(:base_url)
  end

  defp get_config(key) do
    :mediate
    |> Application.fetch_env!(:auth0)
    |> Map.fetch!(key)
    |> then(&{:ok, &1})
  end
end
