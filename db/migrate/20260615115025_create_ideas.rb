class CreateIdeas < ActiveRecord::Migration[8.1]
    def change
        create_table :ideas, id: :uuid do |t|
            t.references :user, null: false, foreign_key: true, type: :uuid
            t.string :title, null: false
            t.jsonb :description, null: false, default: {}
            t.timestamps
        end
    end
end
