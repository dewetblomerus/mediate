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
    Req.Test.stub(Mediate.OpenAi, fn conn ->
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

    sender = users |> hd()

    message_params = %{
      "thread_id" => thread.id,
      "sender_id" => sender.id,
      "body" => "I don't want to talk about this right now"
    }

    result = Mediate.Generator.generate(thread, message_params, sender)

    assert %{"mock" => "response"} = result
  end
end
