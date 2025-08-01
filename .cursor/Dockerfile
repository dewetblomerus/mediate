# Development Dockerfile for Mediate Elixir/Phoenix Application
FROM hexpm/elixir:1.18.4-erlang-28.0.2-debian-bookworm-20250721-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

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

# Install system dependencies and development tools
RUN apt-get update && apt-get install -y \
    # Core system tools
    build-essential \
    curl \
    git \
    unzip \
    wget \
    # Database tools
    postgresql-client \
    # Node.js (for Phoenix assets)
    nodejs \
    npm \
    # Development utilities
    vim \
    nano \
    htop \
    tree \
    jq \
    # Image processing (often needed for Phoenix apps)
    imagemagick \
    # SSL/TLS tools
    ca-certificates \
    openssl \
    # Process monitoring
    procps \
    # Network tools
    netcat-openbsd \
    telnet \
    # Compression tools
    zip \
    unzip \
    # File utilities
    file \
    less \
    # Shell utilities
    zsh \
    # File system watching (for Phoenix live-reload)
    inotify-tools \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI for development workflow
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install gh -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /workspace



# Install rebar3 and hex for Elixir development
RUN mix local.hex --force && \
    mix local.rebar --force

# Install Phoenix generator
RUN mix archive.install hex phx_new --force

# Expose Phoenix default port
EXPOSE 4000

# Default command - start an interactive shell
CMD ["/bin/bash"]

# Development notes:
# - Clone your repository after building: git clone <your-repo> /home/developer/project
# - Run mix setup to install dependencies and set up the database
# - Start the server with: mix phx.server
# - Access the application at http://localhost:4000
