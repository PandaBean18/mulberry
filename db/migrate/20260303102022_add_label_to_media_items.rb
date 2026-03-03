class AddLabelToMediaItems < ActiveRecord::Migration[8.1]
    def change
        add_column :media_items, :label, :string, null: false, default: 'portfolio'

		add_index :media_items, :label
    end
end
