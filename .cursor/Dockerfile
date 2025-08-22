FROM ghcr.io/dewetblomerus/cursor-elixir-dev-base:latest

ENV MIX_ENV=dev
ENV PHX_SERVER=true
ENV PHX_HOST=localhost
ENV PORT=4000

WORKDIR /workspace
CMD ["/bin/bash"]

# Default database configuration for development (override via docker-compose or runtime)
ENV DB_SSL=true

# Auth0 non-secret configuration
ENV AUTH0_REDIRECT_URI=http://localhost:4000/auth
ENV AUTH0_BASE_URL=https://dewet-dev.us.auth0.com

# Development notes:
# - Clone your repository after building: git clone <your-repo> /home/developer/project
# - Run `mix setup` to install dependencies and set up the database
# - Start the server with: mix phx.server
# - Access the application at http://localhost:4000
