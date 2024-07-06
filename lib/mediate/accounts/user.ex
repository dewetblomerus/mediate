defmodule Mediate.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Mediate.Accounts,
    extensions: [AshAuthentication]

  code_interface do
    domain Mediate.Accounts

    define :get_by, action: :get_by
  end

  attributes do
    integer_primary_key :id
    attribute :email, :ci_string, allow_nil?: false
    attribute :auth0_id, :string, allow_nil?: false, public?: false
    attribute :email_verified, :boolean
    attribute :picture, :string
    attribute :name, :string

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  aggregates do
    list :participating_threads, :threads do
    end
  end

  identities do
    identity :unique_email, [:email]
    identity :unique_auth0_id, [:auth0_id]
  end

  relationships do
    many_to_many :threads, Mediate.Chat.Thread do
      through Mediate.Chat.ThreadUser
      source_attribute_on_join_resource :user_id
      destination_attribute_on_join_resource :thread_id
    end
  end

  authentication do
    domain(Mediate.Accounts)

    strategies do
      auth0 do
        client_id Mediate.Secrets
        redirect_uri Mediate.Secrets
        client_secret Mediate.Secrets
        base_url Mediate.Secrets
      end
    end
  end

  actions do
    defaults [:read]

    create :register_with_auth0 do
      argument :user_info, :map, allow_nil?: false
      argument :oauth_tokens, :map, allow_nil?: false
      upsert? true
      upsert_identity :unique_auth0_id

      change fn changeset, _ ->
        user_info = Ash.Changeset.get_argument(changeset, :user_info)

        changes =
          user_info
          |> Map.take([
            "email_verified",
            "email",
            "name",
            "picture"
          ])
          |> Map.put("auth0_id", Map.get(user_info, "sub"))

        Ash.Changeset.change_attributes(
          changeset,
          changes
        )
      end
    end

    read :get_by do
      get_by [:email]
    end
  end

  postgres do
    table "users"
    repo Mediate.Repo
  end
end
