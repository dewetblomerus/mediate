defmodule Mediate.Mistral do
  def generate(messages, _user_id) do
    result =
      [
        method: :post,
        url: "/v1/chat/completions",
        base_url: "https://api.mistral.ai",
        auth: {:bearer, Application.fetch_env!(:mediate, :mistral_api_key)},
        json: %{
          model: "mistral-large-latest",
          messages: messages
        }
      ]
      |> Keyword.merge(Application.get_env(:mediate, :req_options, []))
      |> Req.new()
      |> Req.Request.run_request()

    {%Req.Request{}, %Req.Response{body: response_body}} = result

    response_body
  end
end
