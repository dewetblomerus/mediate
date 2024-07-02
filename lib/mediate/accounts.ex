defmodule Mediate.Accounts do
  use Ash.Domain

  resources do
    resource Mediate.Accounts.User
  end
end
