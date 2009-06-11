class ShouterTables < ActiveRecord::Migration
  def self.up
    create_table :shouter_events, :force => true do |t|
      t.references :target, :polymorphic => true
      t.references :actor
      t.string :name, :null => false
      t.string :actors_cache
      t.timestamps
    end

    create_table :shouter_event_actor_attachments, :force => true do |t|
      t.references :event
      t.references :actor, :polymorphic => true
    end

    create_table :shouter_event_owner_attachments, :force => true do |t|
      t.references :event
      t.references :owner, :polymorphic => true
    end

    create_table :shouter_actions, :force => true do |t|
      t.references :event
      t.references :subject, :polymorphic => true
    end
  end

  def self.down
    %w(
      shouter_events
      shouter_event_actor_attachments
      shouter_event_owner_attachments
      shouter_actions
    ).each do |table|
      drop_table :table
    end
  end
end
