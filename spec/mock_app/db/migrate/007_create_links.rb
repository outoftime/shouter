class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links, :force => true do |t|
      t.references :source, :polymorphic => true
      t.references :target, :polymorphic => true
    end
  end

  def self.down
    drop_table :links
  end
end
