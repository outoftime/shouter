ActiveRecord::Schema.define(:version => 0) do |t|
  create_table :posts, :force => true do |t|
    t.string :headline
    t.datetime :published_at
  end

  create_table :comments, :force => true do |t|
    t.references :user
    t.references :commentable, :polymorphic => true
    t.text :comment
  end

  create_table :photos, :force => true do |t|
    t.string :caption
  end

  create_table :photo_attachments, :force => true do |t|
    t.references :photo
    t.references :user
    t.references :target, :polymorphic => true
  end

  create_table :users, :force => true do |t|
    t.string :name
  end

  create_table :posts_users, :id => false, :force => true do |t|
    t.references :post
    t.references :user
  end

  create_table :links, :force => true do |t|
    t.references :source, :polymorphic => true
    t.references :target, :polymorphic => true
  end

  ### PLUGIN TABLES ###
  
  create_table :shouter_events, :force => true do |t|
    t.references :target, :polymorphic => true
    t.references :actor
    t.string :name, :null => false
    t.string :actors_cache
    t.timestamps
    t.datetime :published_at #XXX not part of standard schema!
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
