defmodule Mediate.Repo do
  use Ecto.Repo,
    otp_app: :mediate,
    adapter: Ecto.Adapters.Postgres
end
