class CreateChildren < ActiveRecord::Migration[5.1]
  def change
    create_table :children do |t|
      t.string :child_name, null:false
      t.datetime :birthday
      t.integer :grade_level
      t.references :user, index: true, foreign_key:true, null: false
    end
  end
end
