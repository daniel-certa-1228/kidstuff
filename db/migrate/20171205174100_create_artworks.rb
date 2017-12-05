class CreateArtworks < ActiveRecord::Migration[5.1]
  def change
    create_table :artworks do |t|

      t.timestamps
    end
  end
end
