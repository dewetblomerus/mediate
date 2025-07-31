# Development Dockerfile for Mediate Elixir/Phoenix Application
FROM hexpm/elixir:1.18.3-erlang-27.3.3-ubuntu-jammy-20240808

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

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
    netcat \
    telnet \
    # Compression tools
    zip \
    unzip \
    # File utilities
    file \
    less \
    # Shell utilities
    zsh \
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

# Install asdf version manager for development flexibility
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0 \
    && echo '. ~/.asdf/asdf.sh' >> ~/.bashrc \
    && echo '. ~/.asdf/completions/asdf.bash' >> ~/.bashrc

# Add asdf to PATH
ENV PATH="/root/.asdf/bin:/root/.asdf/shims:$PATH"

# Install rebar3 and hex for Elixir development
RUN mix local.hex --force && \
    mix local.rebar --force

# Install Phoenix generator
RUN mix archive.install hex phx_new --force

# Set the working directory
WORKDIR /app

# Create a non-root user for development (optional but recommended)
RUN useradd -m -s /bin/bash developer && \
    echo 'developer ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Expose Phoenix default port
EXPOSE 4000

# Default command - start an interactive shell
CMD ["/bin/bash"]

# Development notes:
# - Clone your repository after building: git clone <your-repo> /app
# - Run mix setup to install dependencies and set up the database
# - Start the server with: mix phx.server
# - Access the application at http://localhost:4000
