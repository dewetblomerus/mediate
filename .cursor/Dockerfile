# Fast Development Dockerfile for Mediate Elixir/Phoenix Application
# Uses pre-built base image with all heavy installations
# Base image setup files are located in: cursor_background_agent_setup/
FROM ghcr.io/dewetblomerus/cursor-elixir-dev-base:latest

# Set default Phoenix environment (can be overridden at runtime)
ENV MIX_ENV=dev
ENV PHX_SERVER=true

# Default database configuration for development (override via docker-compose or runtime)
ENV DB_SSL=true

# Default Phoenix configuration
ENV PHX_HOST=localhost
ENV PORT=4000

# Auth0 non-secret configuration
ENV AUTH0_REDIRECT_URI=http://localhost:4000/auth
ENV AUTH0_BASE_URL=https://dewet-dev.us.auth0.com

# Set the working directory (already set in base image, but explicit for clarity)
WORKDIR /workspace

# Default command - start an interactive shell
CMD ["/bin/bash"]

# Development notes:
# - Clone your repository after building: git clone <your-repo> /home/developer/project
# - Run mix setup to install dependencies and set up the database
# - Start the server with: mix phx.server
# - Access the application at http://localhost:4000
