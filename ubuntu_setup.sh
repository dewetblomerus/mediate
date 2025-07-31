#!/bin/bash

# Ubuntu Setup Script for Mediate Project
# This script sets up a new Ubuntu development machine with asdf and project dependencies

set -e  # Exit on any error

echo "🚀 Setting up Ubuntu development environment for Mediate project..."

# Update package list
echo "📦 Updating package list..."
sudo apt update

# Install essential dependencies for asdf and Erlang/Elixir compilation
echo "🔧 Installing essential build dependencies..."
sudo apt install -y \
  automake \
  autoconf \
  build-essential \
  curl \
  git \
  libncurses5-dev \
  libssl-dev \
  libwxgtk3.0-gtk3-dev \
  libwxgtk-webview3.0-gtk3-dev \
  m4 \
  unixodbc-dev \
  xsltproc \
  fop \
  libxml2-utils \
  libncurses-dev \
  openjdk-11-jdk

# Install PostgreSQL client (for connecting to cloud database)
echo "🐘 Installing PostgreSQL client..."
sudo apt install -y postgresql-client

# Install Node.js dependencies (for assets compilation)
echo "📦 Installing Node.js dependencies..."
sudo apt install -y nodejs npm

# Clone and install asdf
echo "🔄 Installing asdf version manager..."
if [ ! -d "$HOME/.asdf" ]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
else
  echo "asdf already installed, updating..."
  cd ~/.asdf && git pull
fi

# Add asdf to shell profile
echo "🔧 Configuring asdf in shell profile..."
if ! grep -q "asdf.sh" ~/.bashrc; then
  echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
  echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
fi

# Source asdf for current session
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"

# Add required plugins
echo "🔌 Adding asdf plugins..."
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git || echo "Erlang plugin already added"
asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git || echo "Elixir plugin already added"

# Install versions specified in .tool-versions
echo "📥 Installing language versions from .tool-versions..."
asdf install

# Install hex and rebar for Elixir
echo "🔧 Installing Hex and Rebar..."
mix local.hex --force
mix local.rebar --force

# Note: PostgreSQL user setup skipped - using cloud database

# Install project dependencies and setup assets
echo "📦 Installing project dependencies..."
mix deps.get

# Setup assets (database setup skipped - using cloud database)
echo "🎨 Setting up assets..."
mix assets.setup
mix assets.build

echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Restart your terminal or run: source ~/.bashrc"
echo "2. Verify installation with: asdf current"
echo "3. Configure your cloud database connection in config/dev.exs"
echo "4. Start the development server with: mix phx.server"
echo ""
echo "🔗 The application will be available at: http://localhost:4000"
echo "💡 Note: Database migrations will need to be run against your cloud database"
