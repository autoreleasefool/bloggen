# frozen_string_literal: true

require_relative 'posts/posts'
require_relative 'tags/tags'
require 'fileutils'

class Bloggen

  def initialize(blogname, posts_source, images_source, tags_file, dest)
    @blogname = blogname
    @posts_source_dir = posts_source
    @images_source_dir = images_source
    @tags_file = tags_file
    @dest_dir = dest
  end

  def generate
    # Remove existing posts
    Posts::clean(@dest_dir)

    # Publish each post that's valid
    posts = Posts::collect(@blogname, @posts_source_dir)
    posts.each { |p| p.publish(@dest_dir) }
    posts.each { |p| p.publish_images(@images_source_dir, "#{@dest_dir}/assets/posts") }

  end

end
