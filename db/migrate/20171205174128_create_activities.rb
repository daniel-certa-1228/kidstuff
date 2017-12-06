class CreateActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :activities do |t|
      t.string :title
      t.datetime :date
      t.datetime :time
      t.string :content
      t.attachment :avatar
      t.timestamps
    end
  end
end
