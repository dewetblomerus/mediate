FROM dewetblomerus/cursor-elixir-dev-base:latest

# Running as root for development (not recommended for production)
WORKDIR /root

# Set basic environment for Elixir development
ENV MIX_ENV=dev

# Default database configuration for development (override via docker-compose or runtime)
ENV DB_SSL=true

# Development notes:
# - Code will be cloned by the background agent into this directory
# - Run `mix setup` to install dependencies and set up the database
# - Start the server with: mix phx.server
# - Configure specific ports and hosts via environment.json or runtime as needed

CMD ["/bin/bash"]
