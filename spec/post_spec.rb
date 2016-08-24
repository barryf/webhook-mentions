describe Post do

  before do
    filename = "_posts/2016-08-24-an-example-post.md"
    front_matter_full = <<-EOS
---
name: A new post
date: #{Time.now.to_s}
slug: my-custom-slug
categories:
- one
- two
---
Full post.
EOS
    @post_full = Post.new(filename, front_matter_full)
    front_matter_simple = <<-EOS
---
name: A simple post
---
Simple post.
EOS
    @post_simple = Post.new(filename, front_matter_simple)
  end

  describe "#initialize" do
    describe "given content with front matter" do
      it "should parse the front matter into a hash" do
        expect(@post_full.front_matter).to be_a(Hash)
      end
    end
  end

  describe "#categories" do
    describe "given front matter with two categories" do
      it "should return a slash separated list of those categories" do
        expect(@post_full.categories).to eql("one/two")
      end
    end
  end

  describe "#slug" do
    describe "given a custom slug" do
      it "should respect that slug" do
        expect(@post_full.slug).to eql("my-custom-slug")
      end
    end
    describe "with no slug" do
      it "should derive a slug from the filename" do
        expect(@post_simple.slug).to eql("an-example-post")
      end
    end
  end

  describe "#post_date" do
    describe "with no date specified" do
      it "should parse the date from the filename" do
        expect(@post_simple.post_date).to eql(Date.parse("2016-08-24"))
      end
    end
  end


end