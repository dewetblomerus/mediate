import Config

config :mediate,
  auth0: %{
    client_id: "auth0-client-id",
    redirect_uri: "http://localhost:4000/auth",
    client_secret: "auth0-client-secret",
    base_url: "https://auth0-domain"
  }

config :mediate,
  openapi_key: "your-openai-api-key",
  mistral_api_key: "your-mistral-api-key"
