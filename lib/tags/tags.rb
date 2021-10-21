# frozen_string_literal: true

require_relative 'tag'
require 'yaml'

# Clean, collect, and generate `Tag`s
module Tags
  def self.clean(base_dir)
    FileUtils.rm_rf("#{base_dir}/tags")
    FileUtils.rm_rf("#{base_dir}/assets/tags")
    FileUtils.rm_rf("#{base_dir}/_data/tags.yml")
    FileUtils.mkdir_p("#{base_dir}/tags")
    FileUtils.mkdir_p("#{base_dir}/assets/tags")
  end

  def self.collect(tags_file)
    tags_yaml = YAML.safe_load(File.read(tags_file))
    tags_yaml.map { |t| Tag.new(t['name'], t['slug'], t.key?('image') ? t['image'] : nil) }
  end
end
