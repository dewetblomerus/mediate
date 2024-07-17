defmodule Mediate.OpenAi do
  def generate(messages, user_id) do
    result =
      [
        method: :post,
        url: "/v1/chat/completions",
        base_url: "https://api.openai.com",
        auth: {:bearer, Application.fetch_env!(:mediate, :openai_key)},
        json: %{
          max_tokens: 500,
          messages: messages,
          model: "gpt-4o",
          # temperature: 0.1,
          user: "#{user_id}"
        }
      ]
      |> Keyword.merge(Application.get_env(:mediate, :req_options, []))
      |> Req.new()
      |> Req.Request.run_request()

    {_, %Req.Response{body: response_body}} = result

    response_body
  end
end
