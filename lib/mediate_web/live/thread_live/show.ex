defmodule MediateWeb.ThreadLive.Show do
  use MediateWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Thread <%= @thread.id %>
      <:subtitle>This is a thread record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/threads/#{@thread}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit thread</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id"><%= @thread.id %></:item>
    </.list>

    <.back navigate={~p"/threads"}>Back to threads</.back>

    <.modal
      :if={@live_action == :edit}
      id="thread-modal"
      show
      on_cancel={JS.patch(~p"/threads/#{@thread}")}
    >
      <.live_component
        module={MediateWeb.ThreadLive.FormComponent}
        id={@thread.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        thread={@thread}
        patch={~p"/threads/#{@thread}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:thread, Ash.get!(Mediate.Chat.Thread, id, actor: socket.assigns.current_user))}
  end

  defp page_title(:show), do: "Show Thread"
  defp page_title(:edit), do: "Edit Thread"
end
