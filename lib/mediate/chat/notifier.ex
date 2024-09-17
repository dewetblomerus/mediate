defmodule Mediate.Chat.Notifier do
  alias Ash.Notifier.Notification
  alias Phoenix.PubSub

  def notify(
        %Notification{action: %Ash.Resource.Actions.Create{}} = notification
      ) do
    PubSub.broadcast(
      Mediate.PubSub,
      build_topic(notification.data.thread_id),
      {:message_create, notification.data}
    )

    notification
  end

  def subscribe_to_thread(thread_id) do
    PubSub.subscribe(Mediate.PubSub, build_topic(thread_id))
  end

  defp build_topic(thread_id) do
    "thread_id:#{thread_id}"
  end
end
