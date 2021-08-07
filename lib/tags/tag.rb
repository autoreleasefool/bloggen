# frozen_string_literal: true

require 'fileutils'

class Tag

  def initialize(name, slug, image_path)
    @name = name
    @slug = slug

    return unless image_path != nil
    slash_index = image_path.rindex("/")
    slash_index = image_path.rindex("/", slash_index - image_path.length - 1)
    @image_path = image_path[slash_index + 1..]
  end

  def publish(dest_dir)
    File.open("#{dest_dir}/_data/tags.yml", "a") do |f|
      f.write("- name: #{@name}\n  slug: #{@slug}\n")
      if @image_path != nil
        f.write("  has_image: true\n")
      end
    end

    File.open("#{dest_dir}/tags/#{@slug}.html", "w") do |f|
      f.write("---\n")
      f.write("layout: tag\n")
      f.write("tag: #{@slug}\n")
      f.write("permalink: /tags/#{@slug}\n")
      f.write("---\n")
    end
  end

  def publish_image(source_dir, dest_dir)
    return unless @image_path != nil
    fname = File.basename(@image_path)
    image_dest = "#{dest_dir}/#{fname}"

    FileUtils.cp(
      "#{source_dir}/#{@image_path}",
      image_dest
    )
  end

end