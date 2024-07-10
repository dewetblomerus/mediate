defmodule MediateWeb.MessageLive.Index do
  use MediateWeb, :live_view
  require Ash.Query

  @impl true
  def render(assigns) do
    ~H"""
    <%= @thread.name %>

    <.table id="messages" rows={@streams.messages}>
      <:col :let={{_id, message}} label="Messages"><%= message.body %></:col>

      <:action :let={{_id, message}}>
        <div class="sr-only">
          <.link navigate={~p"/messages/#{message}"}>Show</.link>
        </div>
      </:action>
    </.table>

    <.simple_form
      for={@form}
      id="message-form"
      phx-change="validate"
      phx-submit="save"
    >
      <.input field={@form[:body]} type="text" label="Body" />

      <:actions>
        <.button phx-disable-with="Saving...">Save Message</.button>
      </:actions>
    </.simple_form>
    """
  end

  @impl true
  def mount(%{"thread_id" => thread_id}, _session, socket) do
    messages =
      Mediate.Chat.Message
      |> Ash.Query.filter(thread_id == ^thread_id)
      |> Ash.read!(actor: socket.assigns[:current_user])

    thread =
      Mediate.Chat.Thread.get_by!(%{id: thread_id})

    {:ok,
     socket
     |> assign(%{
       thread_id: thread_id,
       thread: thread,
       message: nil
     })
     |> assign_form()
     |> stream(
       :messages,
       messages
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Message")
    |> assign(:message, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Messages")
    |> assign(:message, nil)
  end

  @impl true
  def handle_info(
        {MediateWeb.MessageLive.FormComponent, {:saved, message}},
        socket
      ) do
    {:noreply, stream_insert(socket, :messages, message)}
  end

  @impl true
  def handle_event("validate", %{"message" => message_params}, socket) do
    {:noreply,
     assign(socket,
       form: AshPhoenix.Form.validate(socket.assigns.form, message_params)
     )}
  end

  def handle_event("save", %{"message" => raw_message_params}, socket) do
    message_params =
      Map.merge(raw_message_params, %{
        "thread_id" => socket.assigns.thread_id,
        "sender_id" => socket.assigns.current_user.id
      })

    case AshPhoenix.Form.submit(socket.assigns.form, params: message_params) do
      {:ok, message} ->
        socket =
          socket
          |> put_flash(
            :info,
            "Message #{socket.assigns.form.source.type}d successfully"
          )
          |> assign_form()

        {:noreply, stream_insert(socket, :messages, message)}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp assign_form(%{assigns: %{message: message}} = socket) do
    form =
      AshPhoenix.Form.for_create(Mediate.Chat.Message, :create,
        as: "message",
        actor: socket.assigns.current_user
      )

    assign(socket, form: to_form(form))
  end
end
