# frozen_string_literal: true

require_relative 'tag'

module Tags

  def Tags.clean(base_dir)
    FileUtils.rm_rf("#{base_dir}/tags")
    FileUtils.rm_rf("#{base_dir}/assets/tags")
    FileUtils.rm_rf("#{base_dir}/_data/tags.yml")
    FileUtils.mkdir_p("#{base_dir}/tags")
    FileUtils.mkdir_p("#{base_dir}/assets/tags")
  end

  def Tags.collect(tags_file)
    parsing_tag = false
    tag_name = nil
    tag_slug = nil
    tag_image = nil
    push_tag = false
    tags = []

    File.foreach(tags_file) do |line|
      if line.start_with?('-') then
        parsing_tag = true
        line = line[1..]

        if tag_name != nil then
          push_tag = true
        end
      elsif !line.start_with?('  ') then
        if tag_name != nil then
          push_tag = true
        end

        parsing_tag = false
      end

      if push_tag then
        tags << Tag.new(tag_name, tag_slug, tag_image)
        tag_name = nil
        tag_slug = nil
        tag_image = nil
        push_tag = false
      end

      next unless parsing_tag

      key, value = line.strip.split(':')
      case key
      when 'name'
        tag_name = value.strip
      when 'slug'
        tag_slug = value.strip
      when 'image'
        tag_image = value.strip
      end
    end

    tags
  end

end