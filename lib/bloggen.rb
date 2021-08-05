# frozen_string_literal: true

require_relative 'post'

class Bloggen

  def initialize(blogname, source, dest)
    @blogname = blogname
    @source_dir = source
    @dest_dir = dest
  end

  def generate
    # Gets posts from files
    posts = Dir.children(@source_dir)
      .map { |f| @source_dir + '/' + f }
      .select { |f| File.file?(f) }
      .map { |f| Post.new(f) }

    # Filter posts that should be published
    posts = posts.select { |p| !p.frontmatter.empty? }
      .select { |p| p.frontmatter['publish'] == 'true' }
      .select { |p| p.frontmatter['blog'] == @blogname }

    # Publish each post that's valid
    posts.each { |p| p.publish(@dest_dir) }
  end

end
