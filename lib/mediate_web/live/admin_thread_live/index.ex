defmodule MediateWeb.AdminThreadLive.Index do
  use MediateWeb, :live_view

  alias Mediate.Chat.Thread

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Threads You Moderate
      <:actions>
        <.link patch={~p"/admin/threads/new"}>
          <.button>New Thread</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="threads"
      rows={@streams.threads}
      row_click={fn {_id, thread} -> JS.navigate(~p"/admin/threads/#{thread}") end}
    >
      <:col :let={{_id, thread}} label="Id">{thread.id}</:col>
      <:col :let={{_name, thread}} label="Name">{thread.name}</:col>

      <:action :let={{_id, thread}}>
        <div class="sr-only">
          <.link navigate={~p"/admin/threads/#{thread}"}>Show</.link>
        </div>

        <.link patch={~p"/admin/threads/#{thread}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, thread}}>
        <.link
          phx-click={JS.push("delete", value: %{id: thread.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="thread-modal"
      show
      on_cancel={JS.patch(~p"/admin/threads")}
    >
      <.live_component
        module={MediateWeb.AdminThreadLive.FormComponent}
        id={(@thread && @thread.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        thread={@thread}
        patch={~p"/admin/threads"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :threads,
       Thread.for_mediator!(actor: socket.assigns[:current_user])
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
