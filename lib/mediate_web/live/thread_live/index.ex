defmodule MediateWeb.ThreadLive do
  use MediateWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Your Threads
    </.header>

    <.table
      id="threads"
      rows={@streams.threads}
      row_click={fn {_id, thread} -> JS.navigate(~p"/#{thread}") end}
    >
      <:col :let={{_name, thread}} label="Name"><%= thread.name %></:col>

      <:action :let={{_id, thread}}>
        <div class="sr-only">
          <.link navigate={~p"/#{thread}"}>Show</.link>
        </div>
      </:action>
    </.table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :threads,
       Ash.read!(Mediate.Chat.Thread, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Thread")
    |> assign(
      :thread,
      Ash.get!(Mediate.Chat.Thread, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Thread")
    |> assign(:thread, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Threads")
    |> assign(:thread, nil)
  end

  @impl true
  def handle_info(
        {MediateWeb.AdminThreadLive.FormComponent, {:saved, thread}},
        socket
      ) do
    {:noreply, stream_insert(socket, :threads, thread)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    thread =
      Ash.get!(Mediate.Chat.Thread, id, actor: socket.assigns.current_user)

    Ash.destroy!(thread, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :threads, thread)}
  end
end
