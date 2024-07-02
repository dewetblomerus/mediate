defmodule Mediate.Repo do
  use AshPostgres.Repo, otp_app: :mediate

  def installed_extensions do
    ["ash-functions", "uuid-ossp", "citext"]
  end
end
