# frozen_string_literal: true

class Tag

  attr_reader :name
  attr_reader :slug
  attr_reader :image_path

  def initialize(name, slug, image_path)
    @name = name
    @slug = slug

    return unless image_path != nil
    slash_index = image_path.rindex("/")
    slash_index = image_path.rindex("/", slash_index - image_path.length - 1)
    @image_path = image_path[slash_index + 1..]
  end

end
