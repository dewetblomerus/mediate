defmodule MediateWeb.MessageLive.FormComponent do
  use MediateWeb, :live_component
  alias Mediate.Generator

  @impl true
  def render(assigns) do
    choices = get_choices(assigns)
    assigns = Map.put(assigns, :choices, choices)

    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>
          Let's translate your message for greater clarity
        </:subtitle>
      </.header>

    <.input
      name="message_input"
      value={@suggested_message_body}
      type="text"
      id="user-suggested-message"
      phx-keyup="update_user_suggestion"
    />

      <%= for choice <- @choices do %>
        <div><%= choice["message"]["content"] %></div>
        <.button
          phx-disable-with="Saving..."
          phx-click="send_suggestion"
          phx-value-body={choice["message"]["content"]}
        >
          Send suggested message
        </.button>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("generate", %{"message" => message_params}, socket) do
    choices = get_choices(socket.assigns)
    {:noreply, assign(socket, :choices, choices)}
  end

  defp get_choices(assigns) do
    response =
      Generator.generate(
        assigns.thread,
        assigns.suggested_message_body,
        assigns.current_user
      )

    response["choices"]
  end
end
