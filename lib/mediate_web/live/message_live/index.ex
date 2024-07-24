defmodule MediateWeb.MessageLive.Index do
  use MediateWeb, :live_view
  require Ash.Query
  alias Mediate.Accounts.User
  alias Mediate.Chat.Message
  alias Mediate.Chat.Notifier

  @impl true
  def render(assigns) do
    ~H"""
    <%= @thread.name %>

    <.table id="messages" rows={@streams.messages}>
      <:col :let={{_id, message}}>
        <strong><%= sender_name(message, @participants) %></strong>
        <div><%= message.body %></div>
      </:col>
    </.table>

    <.input
      name="message_input"
      value={@suggested_message_body}
      type="text"
      id="user-suggested-message-input"
      phx-keyup="update_user_suggestion"
    />

    <%= if is_binary(@suggested_message_body) && String.length(@suggested_message_body) > 5 do %>
    <.link patch={~p"/#{@thread_id}/translate"}>
      <.button>Translate</.button>
    </.link>
    <% end %>

    <.modal
      :if={@live_action == :translate}
      id="message-modal"
      show
      on_cancel={JS.patch(~p"/#{@thread_id}")}
    >
      <.live_component
        module={MediateWeb.MessageLive.FormComponent}
        action={@live_action}
        current_user={@current_user}
        id={(@message && @message.id) || :new}
        message={@message}
        sender_id={@current_user.id}
        suggested_message_body={@suggested_message_body}
        choices={[]}
        form={@form}
        thread_id={@thread_id}
        thread={@thread}
        title={@page_title}
        patch={~p"/messages"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(%{"thread_id" => thread_id}, _session, socket) do
    if connected?(socket), do: Notifier.subscribe_to_thread(thread_id)

    messages =
      Message.for_thread!(%{thread_id: thread_id})

    thread =
      Mediate.Chat.Thread.get_by!(%{id: thread_id})

    participants =
      User
      |> Ash.Query.for_read(:for_thread, %{thread_id: thread_id})
      |> Ash.Query.select([:id, :name, :picture])
      |> Ash.read!()
      |> Enum.reduce(%{}, fn participant, acc ->
        Map.put(acc, participant.id, participant)
      end)

    {:ok,
     socket
     |> assign(%{
       message: nil,
       suggested_message_body: nil,
       participants: participants,
       thread_id: thread_id,
       thread: thread
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

  defp apply_action(socket, :translate, _params) do
    socket
    |> assign(:page_title, "Translate Message")
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
  def handle_info(
        {:message_create, message},
        socket
      ) do
    {:noreply, stream_insert(socket, :messages, message)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"message" => %{"body" => suggested_message_body} = message_params},
        socket
      ) do
    {:noreply,
     assign(socket,
       form: AshPhoenix.Form.validate(socket.assigns.form, message_params),
       suggested_message_body: suggested_message_body
     )}
  end

  @impl true
  def handle_event(
        "update_user_suggestion",
        %{"key" => "Enter", "value" => user_suggested_message},
        socket
      ) do
    {:noreply, push_patch(socket, to: ~p"/#{socket.assigns.thread_id}/translate")}
  end

  @impl true
  def handle_event(
        "update_user_suggestion",
        %{"value" => user_suggested_message},
        socket
      ) do
    {:noreply, assign(socket, :suggested_message_body, user_suggested_message)}
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

  @impl true
  def handle_event("send_suggestion", %{"body" => message_body}, socket) do
    {:ok, message} =
      Message.create(%{
        body: message_body,
        thread_id: socket.assigns.thread_id,
        sender_id: socket.assigns.current_user.id
      })

    {:noreply,
     socket
     |> assign(:suggested_message_body, "")
     |> stream_insert(:messages, message)
     |> push_patch(to: ~p"/#{socket.assigns.thread_id}")}
  end

  defp assign_form(%{assigns: %{message: _message}} = socket) do
    form =
      AshPhoenix.Form.for_create(Mediate.Chat.Message, :create,
        as: "message",
        actor: socket.assigns.current_user
      )

    assign(socket, form: to_form(form))
  end

  defp sender_name(%Message{} = message, participants) do
    participant = participants[message.sender_id]
    participant.name
  end
end
