defmodule Mediate.Chat.Message do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Mediate.Chat

  attributes do
    integer_primary_key :id
    attribute :body, :string, allow_nil?: false

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :thread,
               Mediate.Chat.Thread,
               attribute_type: :integer,
               allow_nil?: false

    belongs_to :sender,
               Mediate.Accounts.User,
               attribute_type: :integer,
               allow_nil?: false
  end

  postgres do
    table "messages"
    repo Mediate.Repo

    references do
      reference :thread,
        on_delete: :delete,
        on_update: :update,
        name: "messages_thread_id_fkey"

      reference :sender,
        on_delete: :delete,
        on_update: :update,
        name: "messages_sender_id_fkey"
    end
  end
end
