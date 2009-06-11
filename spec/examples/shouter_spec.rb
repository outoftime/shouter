require File.join(File.dirname(__FILE__), 'spec_helper')

describe Shouter do
  describe 'on simple object creation' do
    before :each do
      @post = Post.create! do |post|
        post.users = [@user = User.create!]
      end
      @event = Shouter::Event.last
    end

    it 'should create a shout event targeted at the created object' do
      @event.target.should == @post
    end

    it 'should create a shout event with the given name' do
      @event.name.should == 'post_created'
    end

    it 'should attach actors' do
      @event.actors.should == [@user]
    end

    it 'should set subject to target' do
      @event.actions.first.subject.should == @post
    end
  end

  describe 'on non-grouped secondary object creation' do
    before :each do
      @post = Post.create! do |post|
        post.users = [@author = User.create!]
      end
      @comment = Comment.create! do |comment|
        comment.commentable = @post
        comment.user = @commenter = User.create!
      end
      @event = Shouter::Event.last
    end

    it 'should create a shout event targeted at the post' do
      @event.target.should == @post
    end

    it 'should attach a shout action whose subject is the comment' do
      @event.actions.first.subject.should == @comment
    end

    it 'should set the actor to the comment creator' do
      @event.actors.should == [@commenter]
    end

    it 'should set the owner to the post creator' do
      @event.owners.should == [@author]
    end

    it 'should not group' do
      Comment.create! do |comment|
        comment.commentable = @post
        comment.user = @commenter
      end
      Shouter::Event.named('commented').count.should == 2
    end
  end

  describe 'on grouped object creation' do
    before :each do
      @source_post = Post.create!
      @linked_posts = Array.new(2) { |i| Post.create! }
    end

    describe 'objects in the same group' do
      before :each do
        @links = @linked_posts.map do |linked_post|
          Link.create! do |link|
            link.source = @source_post
            link.target = linked_post
          end
        end
        @event = Shouter::Event.last
      end

      it 'should create only one shout event for the links' do
        Shouter::Event.named('post_linked').count.should == 1
      end

      it 'should attach the event to the target' do
        @event.target.should == @source_post
      end

      it 'should create an action for each attached link' do
        @event.actions.map { |action| action.subject }.to_set.should == 
          @linked_posts.to_set
      end
    end

    describe 'objects with different targets' do
      before :each do
        @source_posts = [@source_post, Post.create!]
        @linked_posts = Array.new(2) { |i| Post.create! }
        @source_posts.each_with_index do |source_post, i|
          Link.create! do |link|
            link.source = source_post
            link.target = @linked_posts[i]
          end
        end
      end

      it 'should not group the actions' do
        Shouter::Event.named('post_linked').count.should == 2
      end
    end
  end

  describe 'on expiring grouped object creation' do
    before :each do
      stop_time!
      @post = Post.create!
      @user = User.create!
      @photo = @post.new_photo(@user)
    end

    it 'should group actions that are within the expiration' do
      photo2 = @post.new_photo(@user)
      Shouter::Event.named('photo_attached').count.should == 1
    end

    it 'should not group actions that are outside the expiration' do
      stop_time!(Time.now + 30.minutes)
      photo2 = @post.new_photo(@user)
      Shouter::Event.named('photo_attached').count.should == 2
    end
  end

  describe 'copy fields' do
    before :each do
      @post = Post.create! do |post|
        post.published_at = @time = Time.mktime(2009, 06, 01, 9, 30)
      end
      @event = Shouter::Event.last
    end

    it 'should copy field into event' do
      @event.published_at.should == @time
    end

    it 'should update the field when the source changes' do
      new_time = Time.mktime(2009, 07, 01, 9, 30)
      @post.update_attributes!(:published_at => new_time)
      @event.reload.published_at.should == new_time
    end
  end
end
