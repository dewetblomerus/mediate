defmodule Mediate.Generator do
  alias Mediate.Chat.Thread
  alias Mediate.OpenAi
  alias Mediate.Accounts.User

  def generate(
        %Thread{} = raw_thread,
        %{
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
    --- Begin mediator notes ---
    #{thread.mediator_notes}
    --- End mediator notes ---

    Here is the proposed next message in the conversation from #{identified_name(sender)}:
    --- Begin proposed message ---
    #{proposed_message_body}
    --- End proposed message ---

    Your job is to re-word the proposed message if needed to help the reader
    understand what the author meant.

    The re-worded message should be written from #{identified_name(sender)} and
    addressed to the other party in the conversation.

    - The mediator notes are extremely important and should take precedence
    over everything else.
    - Do not respond to the proposed message in any way, only re-word it.
    - Do not address #{identified_name(sender)} in your revised message.
    - Do not make statements coming from yourself in your revised message.
    - Do not change any of the main points in the proposed message.
    - Maintain the intent of the proposed message in your revised message.
    - Include all the points from the proposed message in your revised message.
    - Do not try to be an expert and drive the conversation to a resolution.
    - Do not say anything about the message like: 'Here is a response from
    #{sender.name} to the previous message.
    - Take any insults out of the proposed message.
    - Your message should be at most 3 times as long as the proposed message.
    """

    transformed_messages =
      thread.messages
      |> Enum.map(&transform_message(&1, users_map))

    messages = [
      %{role: "system", content: system_message}
      | transformed_messages
    ]

    OpenAi.generate(messages, sender.id)
  end

  defp identified_name(%User{} = user) do
    "#{user.name} with id #{user.id}"
  end

  defp transform_message(%Mediate.Chat.Message{} = message, _users_map) do
    %{
      content: message.body,
      role: "user"
    }
  end
end
