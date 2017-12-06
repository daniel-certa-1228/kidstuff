class CreateArtworks < ActiveRecord::Migration[5.1]
  def change
    create_table :artworks do |t|
      t.string :title
      t.datetime :date
      t.attachment :avatar
      t.timestamps
    end
  end
end
