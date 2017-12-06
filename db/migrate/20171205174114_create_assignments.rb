class CreateAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :assignments do |t|
      t.string :title
      t.datetime :due_date
      t.string :content
      t.attachment :avatar
      t.timestamps
    end
  end
end
