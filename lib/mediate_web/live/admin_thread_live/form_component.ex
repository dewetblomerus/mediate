defmodule MediateWeb.AdminThreadLive.FormComponent do
  use MediateWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>
          Use this form to manage thread records in your database.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="thread-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />

        <.input
          field={@form[:mediator_notes]}
          type="textarea"
          label="Mediator notes"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Thread</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"thread" => thread_params}, socket) do
    {:noreply,
     assign(socket,
       form: AshPhoenix.Form.validate(socket.assigns.form, thread_params)
     )}
  end

  def handle_event("save", %{"thread" => raw_thread_params}, socket) do
    thread_params =
      Map.put(raw_thread_params, "mediator_id", socket.assigns.current_user.id)

    case AshPhoenix.Form.submit(socket.assigns.form, params: thread_params) do
      {:ok, thread} ->
        notify_parent({:saved, thread})

        socket =
          socket
          |> put_flash(
            :info,
            "Thread #{socket.assigns.form.source.type}d successfully"
          )
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{thread: thread}} = socket) do
    form =
      if thread do
        AshPhoenix.Form.for_update(thread, :update,
          as: "thread",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Mediate.Chat.Thread, :create,
          as: "thread",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
