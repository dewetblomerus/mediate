import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :mediate, Mediate.Repo,
  username: System.fetch_env!("DB_USERNAME"),
  password: System.fetch_env!("DB_PASSWORD"),
  hostname: System.fetch_env!("DB_HOSTNAME"),
  database: "mediate_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mediate, MediateWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base:
    "UQlL1F6zr5ey+WZ08r5YnRhudRK+1RzknmREa0+yif6VGnkdtFhwgADNpxd1Ct4G",
  server: false

# In test we don't send emails
config :mediate, Mediate.Mailer, adapter: Swoosh.Adapters.Test

config :mediate,
  req_options: [
    plug: {Req.Test, Mediate.OpenAi}
  ]

config :mediate,
  openai_key: "test-key"

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
