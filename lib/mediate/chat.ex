defmodule Mediate.Chat do
  use Ash.Domain

  resources do
    resource Mediate.Chat.Thread
    resource Mediate.Chat.ThreadUser
    resource Mediate.Chat.Message
  end
end
