defmodule Mediate.Repo.Migrations.CreateMessages do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:messages, primary_key: false) do
      add :id, :bigserial, null: false, primary_key: true
      add :body, :text, null: false

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :thread_id,
          references(:threads,
            column: :id,
            name: "messages_thread_id_fkey",
            type: :bigint,
            prefix: "public",
            on_delete: :delete_all,
            on_update: :update_all
          ),
          null: false

      add :sender_id,
          references(:users,
            column: :id,
            name: "messages_sender_id_fkey",
            type: :bigint,
            prefix: "public",
            on_delete: :delete_all,
            on_update: :update_all
          ),
          null: false
    end
  end

  def down do
    drop constraint(:messages, "messages_thread_id_fkey")

    drop constraint(:messages, "messages_sender_id_fkey")

    drop table(:messages)
  end
end
