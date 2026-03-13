class CreateCalendarEntries < ActiveRecord::Migration[8.1]
	def change
		create_table :calendar_entries, id: :uuid do |t|
			t.references :user, null: false, type: :uuid, foreign_key: true
			t.references :deliverable, null: true, type: :uuid, foreign_key: true

			t.string :title, null: false
			t.text :brief
			t.datetime :date, null: false
			t.string :entry_type, null: false
			t.boolean :is_completed, default: false, null: false

			t.timestamps
		end
		add_index :calendar_entries, :date
		add_index :calendar_entries, :is_completed
	end
end
