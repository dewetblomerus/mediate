defmodule Mediate.Generator do
  alias Mediate.Chat.Thread
  alias Mediate.OpenAi
  alias Mediate.Accounts.User

  def generate(
        %Thread{} = raw_thread,
        %{
          "sender_id" => sender_id,
          "body" => proposed_message_body
        },
        %User{} = sender
      ) do
    thread =
      Ash.load!(raw_thread, [:mediator, :users, :messages])

    mediator = thread.mediator

    user_name_list =
      thread.users
      |> Enum.map(&identified_name/1)
      |> Enum.join(" and ")

    users_map =
      thread.users
      |> Enum.reduce(%{}, fn user, acc ->
        Map.put(acc, user.id, user)
      end)

    system_message = """
    #{identified_name(mediator)} is the best mediator in the world.

    #{user_name_list} have come to #{identified_name(mediator)} for mediation.

    Here are #{identified_name(mediator)}'s notes about the situation:
    #{thread.mediator_notes}

    Here is the proposed next message in the conversation from #{identified_name(sender)}:
    #{proposed_message_body}

    Your job is to come up with a re-worded message, or just repeat the proposed
    message if it already serves the goal.

    The goal is to let the parties reach an understanding between themselves.

    Address your message to the same participant that
    #{identified_name(sender)} addressed their proposed message to.

    - Do not address #{identified_name(sender)} in your revised message.
    - Do not make statements coming from yourself in your revised message.
    - Do not change the topic of the conversation in your revised message.
    - Maintain the intent of the proposed message in your revised message.
    - Do not try to be an expert and drive the conversation to a resolution,
    just help the parties to acknowledge each other's perspectives and
    state their own points in a way that is understood by others.
    - Do not say anything about the message like: 'Here is a response from
    #{sender.name} to the previous message.
    - Keep the message addressed to the same participant that the proposed
    - If the proposed message does not already contain it, and the previous
    message had a point that has not been acknowledged, include acknowledgement
    of that point in your revised message

    Your message should be at most 3 times as long as the proposed message.
    """

    transformed_messages =
      thread.messages
      |> Enum.map(&transform_message(&1, users_map))

    messages = [
      %{role: "system", content: system_message}
      | transformed_messages
    ]

    response = OpenAi.generate(messages, sender_id)
  end

  defp identified_name(%User{} = user) do
    "#{user.name} with id #{user.id}"
  end

  defp normalized_name(%User{} = user) do
    "#{user.name}-#{user.id}"
    |> String.replace(~r/\s+/, "-")
  end

  defp transform_message(%Mediate.Chat.Message{} = message, users_map) do
    %{
      content: message.body,
      # name: normalized_name(users_map[message.sender_id]),
      role: "user"
    }
  end
end
