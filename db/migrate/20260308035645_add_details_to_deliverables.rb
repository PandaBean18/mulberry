class AddDetailsToDeliverables < ActiveRecord::Migration[8.1]
    def change
        add_column :deliverables, :due_date, :datetime
        add_column :deliverables, :brief, :text

		add_index :deliverables, :due_date
    end
end
