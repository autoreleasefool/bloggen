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
    Dir.glob("#{source_dir}/**/*.md")
      .select { |f| File.file?(f) }
      .map { |f| Post.new(f) }
      .select { |p| p.has_frontmatter }
      .select { |p| p.frontmatter['blog'] == blogname }
  end
end