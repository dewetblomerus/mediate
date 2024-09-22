defmodule Mediate.GeneratorTest do
  use Mediate.DataCase, async: true
  import ExUnit.Assertions
  alias Mediate.Chat.Message
  alias Mediate.Chat.Thread
  alias Mediate.Chat.ThreadUser
  alias Mediate.Factory

  setup do
    users = [
      Factory.user_factory(),
      Factory.user_factory()
    ]

    admin_user = Factory.admin_user()
    %{users: users, admin_user: admin_user}
  end

  test "generate", %{users: users, admin_user: admin_user} do
    [user1, user2] = users
    user1_identified_name = Mediate.Generator.identified_name(user1)
    user2_identified_name = Mediate.Generator.identified_name(user2)

    Req.Test.stub(Mediate.OpenAi, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)
      json_body = Jason.decode!(body)
      user1_id = "#{user1.id}"

      assert %{
               "model" => "gpt-4o",
               "max_tokens" => 500,
               "user" => ^user1_id,
               "messages" => [
                 %{
                   "content" => _system_message,
                   "role" => "system"
                 },
                 %{
                   "content" => "I would like to have 100% for myself",
                   "name" => ^user1_identified_name,
                   "role" => "user"
                 },
                 %{
                   "content" => "I would like to have 100% for myself",
                   "name" => ^user2_identified_name,
                   "role" => "user"
                 }
               ]
             } = json_body

      assert %Plug.Conn{
               halted: false,
               host: "api.openai.com",
               method: "POST",
               params: %{},
               path_info: ["v1", "chat", "completions"],
               path_params: %{},
               port: 443,
               private: %{},
               query_params: %{},
               query_string: "",
               remote_ip: {127, 0, 0, 1},
               request_path: "/v1/chat/completions",
               req_headers: [
                 {"accept", "application/json"},
                 {"accept-encoding", "gzip"},
                 {"authorization", "Bearer test-key"},
                 {"content-type", "application/json"},
                 {"user-agent", _}
               ]
             } = conn

      Req.Test.json(conn, %{"mock" => "response"})
    end)

    assert {:ok, thread = %Thread{}} =
             Thread.create(
               %{
                 name: "Thread Name test",
                 mediator_notes: "I think they can work it out"
               },
               actor: admin_user
             )

    users
    |> Enum.each(fn user ->
      ThreadUser.create(%{thread_id: thread.id, user_id: user.id},
        actor: admin_user
      )

      Message.create(%{
        thread_id: thread.id,
        sender_id: user.id,
        body: "I would like to have 100% for myself"
      })
    end)

    sender = user1

    suggested_message_body = "I don't want to talk about this right now"

    result = Mediate.Generator.generate(thread, suggested_message_body, sender)

    assert %{"mock" => "response"} = result

    Req.Test.verify!(Mediate.OpenAi)
  end
end
