class ChangeMessageIdToUuid < ActiveRecord::Migration[8.1]
    def up
		add_column :messages, :uuid, :uuid, default: -> { "gen_random_uuid()" }, null: false
		remove_column :messages, :id
		rename_column :messages, :uuid, :id
		execute "ALTER TABLE messages ADD PRIMARY KEY (id);"
    end
end
