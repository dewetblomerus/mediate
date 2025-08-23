FROM dewetblomerus/cursor-elixir-dev-base:latest

# Fix apt repository time sync issues
RUN echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until && \
    echo 'Acquire::Check-Date "false";' >> /etc/apt/apt.conf.d/99no-check-valid-until && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Running as root for development (not recommended for production)
WORKDIR /workspace

# Set basic environment for Elixir development
ENV MIX_ENV=dev

# Default database configuration for development (override via docker-compose or runtime)
ENV DB_SSL=true

# Development notes:
# - Code will be cloned by the background agent into /workspace
# - Run `mix setup` to install dependencies and set up the database
# - Start the server with: mix phx.server
# - Configure specific ports and hosts via environment.json or runtime as needed

CMD ["/bin/bash"]
