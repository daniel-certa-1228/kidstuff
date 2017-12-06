class CreateAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :assignments do |t|
      t.string :title
      t.datetime :due_date
      t.string :content
      t.attachment :avatar
      t.references :child
      t.references :user, index: true, foreign_key:true, null: false
      t.timestamps
    end
  end
end
