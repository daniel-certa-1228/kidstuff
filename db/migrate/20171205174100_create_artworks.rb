class CreateArtworks < ActiveRecord::Migration[5.1]
  def change
    create_table :artworks do |t|
      t.string :title
      t.datetime :date
      t.attachment :avatar
      t.references :child
      t.references :user, index: true, foreign_key:true, null: false
      t.timestamps
    end
  end
end
