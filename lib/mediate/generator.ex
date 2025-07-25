defmodule Mediate.Generator do
  alias Mediate.Accounts.User
  alias Mediate.Chat.Thread

  @api_client Mediate.OpenAi
  # @api_client Mediate.Mistral

  def generate(
        %Thread{} = raw_thread,
        proposed_message_body,
        %User{} = sender
      ) do
    thread =
      Ash.load!(raw_thread, [:mediator, :users, messages: [:sender]])

    mediator = thread.mediator

    user_name_list = Enum.map_join(thread.users, " and ", &identified_name/1)

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

    Your job is to re-word the proposed message if needed.

    - The re-worded message should be written from #{identified_name(sender)} and
      addressed to the other party in the conversation.
    - Do not respond to the proposed message in any way, only re-word it
      if needed.
    - Do not repeat previous messages, unless the proposed message is also
      a repitition of a previous message.
    - Do not address #{identified_name(sender)} in your revised message.
    - Do not make statements coming from yourself in your revised message.
    - Do not change any of the main points in the proposed message.
    - Maintain the intent of the proposed message in your revised message.
    - Include all the points from the proposed message in your revised message.
    - Do not say anything about the message like: 'Here is a response from
    #{sender.name} to the previous message.
    - Take any insults out of the proposed message.
    - Your message should be at most 3 times as long as the proposed message.
    - Your revised message should not include anything that marks it's start or end.
    """

    transformed_messages =
      thread.messages
      |> Enum.map(&transform_message(&1, users_map))

    messages = [
      %{role: "system", content: system_message}
      | transformed_messages
    ]

    @api_client.generate(messages, sender.id)
  end

  def identified_name(%User{} = user) do
    "#{user.name}-#{user.id}"
    |> String.replace(" ", "-")
  end

  defp transform_message(%Mediate.Chat.Message{} = message, _users_map) do
    %{
      content: message.body,
      name: identified_name(message.sender),
      role: "user"
    }
  end
end
