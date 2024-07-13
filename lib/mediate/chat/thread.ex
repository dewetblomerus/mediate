defmodule Mediate.Chat.Thread do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Mediate.Chat

  code_interface do
    domain Mediate.Chat

    define :get_by, action: :get_by

    define :for_mediator, action: :for_mediator

    define :create, action: :create
  end

  actions do
    defaults [:read, :destroy]

    read :for_mediator do
      filter expr(mediator_id == ^actor(:id))
    end

    create :create do
      accept [:name, :mediator_notes]
      change relate_actor(:mediator)
      primary? true
    end

    update :update do
      accept [:name, :mediator_notes]
      primary? true
    end

    read :get_by do
      get_by [:id]
    end
  end

  attributes do
    integer_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :mediator_notes, :string, allow_nil?: false

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :mediator,
               Mediate.Accounts.User,
               attribute_type: :integer,
               allow_nil?: false

    many_to_many :users, Mediate.Accounts.User do
      through Mediate.Chat.ThreadUser
      source_attribute_on_join_resource :thread_id
      destination_attribute_on_join_resource :user_id
    end

    has_many :messages, Mediate.Chat.Message
  end

  postgres do
    table "threads"
    repo Mediate.Repo

    references do
      reference :mediator,
        on_delete: :delete,
        on_update: :update,
        name: "threads_mediator_id_fkey"
    end
  end

  resource do
    plural_name :threads
  end
end
