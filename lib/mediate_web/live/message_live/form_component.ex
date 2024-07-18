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

      <.simple_form
        for={@form}
        id="message-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="generate"
      >
        <.input field={@form[:body]} type="text" label="Body" value={@suggested_message_body} />

        <:actions>
          <.button phx-disable-with="Generating...">Generate translation</.button>
        </:actions>
      </.simple_form>

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
  def handle_event("validate", %{"message" => message_params}, socket) do
    {:noreply,
     assign(socket,
       form: AshPhoenix.Form.validate(socket.assigns.form, message_params)
     )}
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
