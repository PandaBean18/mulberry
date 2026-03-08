class MakeDueDateNonNullable < ActiveRecord::Migration[8.1]
    def change
		change_column_null :deliverables, :due_date, false
    end
end
