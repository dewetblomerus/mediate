defmodule Mediate.Chat.ThreadUser do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Mediate.Chat

  code_interface do
    domain Mediate.Chat

    define :create, action: :create
    define :delete, action: :destroy
  end

  relationships do
    belongs_to :user,
               Mediate.Accounts.User,
               primary_key?: true,
               allow_nil?: false,
               attribute_type: :integer

    belongs_to :thread,
               Mediate.Chat.Thread,
               primary_key?: true,
               allow_nil?: false,
               attribute_type: :integer
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      accept [:user_id, :thread_id]
      primary? true
    end
  end

  postgres do
    table "thread_users"
    repo Mediate.Repo

    references do
      reference :thread,
        on_delete: :delete,
        on_update: :update,
        name: "thread_users_thread_id_fkey"

      reference :user,
        on_delete: :delete,
        on_update: :update,
        name: "thread_users_user_id_fkey"
    end
  end

  resource do
    plural_name :thread_users
  end
end
