defmodule Mediate.Chat do
  use Ash.Domain

  resources do
    resource Mediate.Chat.Thread
    resource Mediate.Chat.ThreadUser
  end
end
