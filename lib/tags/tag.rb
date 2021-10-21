# frozen_string_literal: true

# A tag, for posts
class Tag
  attr_reader :name, :slug, :image_path

  def initialize(name, slug, image_path)
    @name = name
    @slug = slug

    return if image_path.nil?

    slash_index = image_path.rindex('/')
    slash_index = image_path.rindex('/', slash_index - image_path.length - 1)
    @image_path = image_path[slash_index + 1..]
  end
end
