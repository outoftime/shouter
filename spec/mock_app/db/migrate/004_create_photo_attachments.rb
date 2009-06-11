class CreatePhotoAttachments < ActiveRecord::Migration
  def self.up
    create_table :photo_attachments, :force => true do |t|
      t.references :photo
      t.references :user
      t.references :target, :polymorphic => true
    end
  end

  def self.down
    drop_table :photo_attachments
  end
end
