defmodule MediateWeb.MyComponents do
  @moduledoc """
  Because this is a basic side-project, I'm not going to modify
  core_components.ex too much.
  Instead, I created this file to hold shared components.
  """

  use Phoenix.Component

  alias Mediate.AdminChecker

  # alias Phoenix.LiveView.JS
  # import RedWeb.Gettext

  @doc """
  Renders a Navbar

  ## Examples

      <.navbar current_user={@current_user} />
  """
  attr :current_user, :map

  def navbar(assigns) do
    ~H"""
    <nav class="flex flex-wrap justify-between items-center bg-gray-800 text-white lg:px-8 sm:px-4 px-2">
      <a
        href="/"
        class="text-white text-xl hover:text-grey-200 active:text-grey-400"
      >
        Threads
      </a>
      <%= if @current_user && AdminChecker.super_user?(@current_user) do %>
        <a
          href="/admin/threads"
          class="text-white text-xl hover:text-grey-200 active:text-grey-400"
        >
          Admin Threads
        </a>
      <% end %>
      <div class="flex flex-wrap justify-end items-center gap-3">
        <%= if @current_user do %>
          <img
            src={@current_user.picture}
            alt="Profile Picture"
            style="width:48px;height:48px;border-radius:50%;"
            class="my-1"
          />
          <a
            href="/sign-out"
            class="rounded-lg bg-zinc-100 px-2 py-1 text-[0.8125rem] font-semibold leading-6 text-zinc-900 hover:bg-zinc-200/80 active:text-zinc-900/70"
          >
            Sign out
          </a>
        <% else %>
          <a
            href="/auth/user/auth0"
            class="rounded-lg bg-zinc-100 px-2 py-1 text-[0.8125rem] font-semibold leading-6 text-zinc-900 hover:bg-zinc-200/80 active:text-zinc-900/70 my-3"
          >
            Sign In
          </a>
        <% end %>
      </div>
    </nav>
    """
  end
end
