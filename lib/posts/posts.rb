# frozen_string_literal: true

require_relative 'post'
require 'fileutils'

module Posts
  def Posts.clean(base_dir)
    FileUtils.rm_rf("#{base_dir}/_posts")
    FileUtils.mkdir_p("#{base_dir}/_posts")
    FileUtils.rm_rf("#{base_dir}/assets/posts")
  end

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