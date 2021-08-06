# frozen_string_literal: true

require_relative 'post'

module Posts
  def Posts.collect(blogname, source_dir)
    Dir.children(source_dir)
      .map { |f| "#{source_dir}/#{f}" }
      .select { |f| File.file?(f) }
      .map { |f| Post.new(f) }
      .select { |p| !p.frontmatter.empty? }
      .select { |p| p.frontmatter['publish'] == 'true' }
      .select { |p| p.frontmatter['blog'] == blogname }
  end
end