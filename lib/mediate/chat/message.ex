defmodule Mediate.Chat.Message do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Mediate.Chat

  code_interface do
    domain Mediate.Chat

    define :for_thread, action: :for_thread
    define :create, action: :create
  end

  actions do
    defaults [:destroy, :update, :read]

    read :for_thread do
      argument :thread_id, :integer, allow_nil?: false
      filter expr(thread_id == ^arg(:thread_id))
    end

    create :create do
      accept [:body, :thread_id, :sender_id]
      primary? true
    end
  end

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

  resource do
    plural_name :messages
  end
end
