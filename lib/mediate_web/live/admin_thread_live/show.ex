defmodule MediateWeb.AdminThreadLive.Show do
  use MediateWeb, :live_view

  alias Mediate.Chat.ThreadUser

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@thread.name}

      <:actions>
        <.link
          patch={~p"/admin/threads/#{@thread}/show/edit"}
          phx-click={JS.push_focus()}
        >
          <.button>Edit thread</.button>
        </.link>
      </:actions>
    </.header>

    <.header>
      Users in this thread
    </.header>

    <.table id="users" rows={@streams.users}>
      <:col :let={{_id, user}} label="Id">{user.id}</:col>
      <:col :let={{_name, user}} label="Name">{user.name}</:col>

      <:col :let={{_checkbox, user}} label="Member">
        <.input
          type="checkbox"
          phx-click="toggle_checkbox"
          phx-value-user_id={user.id}
          name="Member Checkbox"
          checked={@thread.id in user.participating_threads}
        />
      </:col>
    </.table>

    <.back navigate={~p"/admin/threads"}>Back to threads</.back>

    <.modal
      :if={@live_action == :edit}
      id="thread-modal"
      show
      on_cancel={JS.patch(~p"/admin/threads/#{@thread}")}
    >
      <.live_component
        module={MediateWeb.AdminThreadLive.FormComponent}
        id={@thread.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        thread={@thread}
        patch={~p"/admin/threads/#{@thread}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    users =
      Mediate.Accounts.User
      |> Ash.Query.load([:participating_threads])
      |> Ash.read!(actor: socket.assigns[:current_user])

    {:ok,
     socket
     |> stream(
       :users,
       users
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :thread,
       Ash.get!(Mediate.Chat.Thread, id, actor: socket.assigns.current_user)
     )}
  end

  @impl true
  def handle_event(
        "toggle_checkbox",
        %{"value" => "true", "user_id" => user_id},
        socket
      ) do
    ThreadUser.create(%{
      user_id: user_id,
      thread_id: socket.assigns.thread.id
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "toggle_checkbox",
        %{"user_id" => user_id},
        socket
      ) do
    ThreadUser.delete(%{
      user_id: user_id,
      thread_id: socket.assigns.thread.id
    })

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Thread"
  defp page_title(:edit), do: "Edit Thread"
end
