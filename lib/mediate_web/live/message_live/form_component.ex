defmodule MediateWeb.MessageLive.FormComponent do
  use MediateWeb, :live_component
  alias Mediate.Generator

  @impl true
  def render(assigns) do
    choices = get_choices(assigns.form.params, assigns)
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
        <.input field={@form[:body]} type="text" label="Body" />

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
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
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
    response =
      Generator.generate(
        socket.assigns.thread,
        message_params,
        socket.assigns.current_user
      )

    choices =
      response["choices"]

    # case AshPhoenix.Form.submit(socket.assigns.form, params: message_params) do
    #   {:ok, message} ->
    #     notify_parent({:saved, message})

    #     socket =
    #       socket
    #       |> put_flash(
    #         :info,
    #         "Message #{socket.assigns.form.source.type}d successfully"
    #       )
    #       |> push_patch(to: socket.assigns.patch)

    #     {:noreply, socket}

    #   {:error, form} ->
    #     {:noreply, assign(socket, form: form)}
    # end
    {:noreply, assign(socket, :choices, choices)}
  end

  defp get_choices(message_params, _assigns) when message_params == %{} do
    []
  end

  defp get_choices(message_params, assigns) do
    response =
      Generator.generate(
        assigns.thread,
        message_params,
        assigns.current_user
      )

    response["choices"]
  end
end
