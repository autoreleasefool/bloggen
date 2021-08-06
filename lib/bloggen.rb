# frozen_string_literal: true

require_relative 'post'
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

    # Collect images from published posts
    images = posts.flat_map { |p| p.collect_images }

    # Clean up images directory before publishing
    images_dest_dir = "#{@dest_dir}/assets/posts"
    FileUtils.rm_rf(images_dest_dir)

    # Copy images to expected file structure
    images.each do |i|
      fname = "#{images_dest_dir}/#{i}"
      FileUtils.mkdir_p(File.dirname(fname))
      FileUtils.cp(
        "#{@images_source_dir}/#{i}",
        fname
      )
    end
  end

end
