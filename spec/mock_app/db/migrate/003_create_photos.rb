class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos, :force => true do |t|
      t.string :caption
    end
  end

  def self.down
    drop_table :photos
  end
end
