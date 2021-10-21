# frozen_string_literal: true

require_relative 'post'
require 'fileutils'

# Clean, collect, and generate `Post`s
module Posts
  def self.clean(base_dir)
    FileUtils.rm_rf("#{base_dir}/_posts")
    FileUtils.mkdir_p("#{base_dir}/_posts")
    FileUtils.rm_rf("#{base_dir}/assets/posts")
  end

  def self.collect(blogname, source_dir)
    Dir.glob("#{source_dir}/**/*.md")
       .select { |f| File.file?(f) }
       .map { |f| Post.new(f) rescue nil } # rubocop:disable Style/RescueModifier
       .compact
       .select(&:frontmatter?)
       .select { |p| p.frontmatter['blog'] == blogname }
  end
end
