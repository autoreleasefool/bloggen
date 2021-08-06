# frozen_string_literal: true

require_relative 'posts/post'
require 'fileutils'

class Bloggen

  def initialize(blogname, posts_source, images_source, dest)
    @blogname = blogname
    @posts_source_dir = posts_source
    @images_source_dir = images_source
    @dest_dir = dest
  end

  def generate
    # Gets posts from files
    posts = Dir.children(@posts_source_dir)
      .map { |f| @posts_source_dir + '/' + f }
      .select { |f| File.file?(f) }
      .map { |f| Post.new(f) }

    # Filter posts that should be published
    posts = posts.select { |p| !p.frontmatter.empty? }
      .select { |p| p.frontmatter['publish'] == 'true' }
      .select { |p| p.frontmatter['blog'] == @blogname }

    # Remove existing posts
    FileUtils.rm_rf("#{@dest_dir}/_posts")
    FileUtils.mkdir_p("#{@dest_dir}/_posts")

    # Publish each post that's valid
    posts.each { |p| p.publish(@dest_dir) }

    # Clean up images directory before publishing
    images_dest_dir = "#{@dest_dir}/assets/posts"
    FileUtils.rm_rf(images_dest_dir)

    # Publish images of each post
    posts.each { |p| p.publish_images(@images_source_dir, images_dest_dir) }
  end

end
