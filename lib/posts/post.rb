# frozen_string_literal: true

require 'date'
require 'yaml'
require 'securerandom'

Image = Struct.new(:id, :caption, :filename)

class Post

  attr_accessor :body

  attr_reader :frontmatter
  attr_reader :title
  attr_reader :images

  @@image_regex = /^!\[(?<Caption>[^\]]+)\]\((?<Filename>[^\)]+)\)/
  @@predefined_frontmatter_keys = %w(layout permalink title date feature_image tags blog publish type)

  def initialize(input_filename)
    parsing_frontmatter = true
    frontmatter = ""
    body = ""
    @images = []
    File.foreach(input_filename).with_index do |line, index|
      next if index == 0

      if parsing_frontmatter then
        if line.chomp == '---' then
          parsing_frontmatter = false
          next
        end

        frontmatter += line
        next
      end

      if @title == nil && line.start_with?('# ') then
        @title = line[1..].strip
      end

      next if @title == nil

      if line.start_with?('![') then
        id = SecureRandom.uuid
        parts = line.match(@@image_regex)
        line = "#{id}\n"
        if parts then
          @images << Image.new(id, parts["Caption"], parts["Filename"])
        end
      end

      body = "#{body}#{line}"
    end

    if frontmatter.empty? then
      raise "File `#{input_filename}` missing frontmatter"
    end

    begin
      @frontmatter = YAML.load(frontmatter)
      @frontmatter = if @frontmatter.key?("bloggen") then @frontmatter["bloggen"] else nil end
    rescue
      @frontmatter = nil
    end

    @body = body
    if !@frontmatter.nil? && @frontmatter.key?('feature_image') then
      @images << Image.new(SecureRandom.uuid, "Feature image", @frontmatter["feature_image"])
    end
  end

  def content
    "#{formatted_frontmatter}#{body}"
  end

  def type
    @frontmatter["type"]
  end

  def filename
    "#{@frontmatter["date"].strftime("%Y-%m-%d")}-#{@frontmatter["permalink"]}"
  end

  def tags
    @frontmatter["tags"].join(' ')
  end

  def feature_image
    @frontmatter.key?('feature_image') ? "feature_image: /assets/#{type}s/#{@frontmatter["feature_image"]}" : nil
  end

  def permalink
    "/#{type}s/#{@frontmatter["permalink"]}"
  end

  def is_published
    @frontmatter["publish"]
  end

  def publish_date
    @frontmatter["date"]
  end

  def is_after_publish_date
    publish_date < Time.now
  end

  def predefined_frontmatter
    [
      "layout: #{type}",
      "permalink: #{permalink}",
      "title: \"#{@title}\"",
      "date: #{publish_date.to_s}",
      feature_image ? feature_image : nil,
      "tags: #{tags}",
    ].compact.join("\n")
  end

  def extra_frontmatter
    extra = @frontmatter
      .select { |key, value| !@@predefined_frontmatter_keys.include?(key) }
      .map { |key, value| "#{key}: #{value}" }
      .join("\n")
    return extra unless extra.empty?
  end

  def formatted_frontmatter
    [
      '---',
      predefined_frontmatter,
      extra_frontmatter,
      '---',
    ].compact.join("\n")
  end

  def has_frontmatter
    !@frontmatter.nil?
  end

end