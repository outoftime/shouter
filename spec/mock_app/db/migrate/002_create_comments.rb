class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments, :force => true do |t|
      t.references :user
      t.references :commentable, :polymorphic => true
      t.text :comment
    end
  end
end
