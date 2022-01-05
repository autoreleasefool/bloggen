# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

require 'date'
require 'fileutils'
require 'securerandom'
require 'yaml'

Image = Struct.new(:id, :caption, :filename) do
  def contextual_filename(context)
    context.strip_absolute_paths ? filename.gsub(%r{.*/}) { '' } : filename
  end
end

# A Blog Post
class Post
  attr_accessor :body
  attr_reader :frontmatter, :title, :images

  def self.image_regex
    /^!\[(?<Caption>[^\]]+)\]\((?<Filename>[^)]+)\)/
  end

  def self.predefined_frontmatter_keys
    %w[layout permalink title date feature_image tags blog publish type]
  end

  def type
    @frontmatter['type']
  end

  def content
    "#{formatted_frontmatter}#{body}"
  end

  def filename
    "#{publish_date.strftime('%Y-%m-%d')}-#{@frontmatter['permalink']}"
  end

  def tags
    @frontmatter['tags'].join(' ')
  end

  def feature_image
    @frontmatter.key?('feature_image') ? "feature_image: /assets/#{type}s/#{@frontmatter['feature_image']}" : nil
  end

  def permalink
    "/#{type}s/#{@frontmatter['permalink']}"
  end

  def published?
    @frontmatter['publish']
  end

  def publish_date
    DateTime.iso8601(@frontmatter['date'])
  rescue Date::Error
    DateTime.now + 1_000_000_000
  end

  def after_publish_date?
    publish_date < DateTime.now
  end

  def predefined_frontmatter
    [
      "layout: #{type}",
      "permalink: #{permalink}",
      "title: \"#{@title}\"",
      "date: #{publish_date}",
      feature_image || nil,
      "tags: #{tags}"
    ].compact.join("\n")
  end

  def extra_frontmatter
    @frontmatter
      .reject { |key, _| self.class.predefined_frontmatter_keys.include?(key) }
      .map { |key, value| "#{key}: #{value}" }
      .join("\n")
  end

  def formatted_frontmatter
    ['---', predefined_frontmatter, extra_frontmatter, '---'].compact.join("\n")
  end

  def frontmatter?
    !@frontmatter.nil? && !frontmatter.empty?
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  def initialize(input_filename)
    @frontmatter = ''
    @body = ''
    @title = nil
    @images = []

    frontmatter_bounds = 2
    @frontmatter = ''

    File.foreach(input_filename) do |line|
      frontmatter_bounds -= 1 if line.chomp == '---'
      @frontmatter += line if frontmatter_bounds.positive?
      next if frontmatter_bounds.positive?

      @title = line[1..].strip if @title.nil? && line.start_with?('# ')

      next if @title.nil?

      if line.start_with?('![')
        id = SecureRandom.uuid
        parts = line.match(self.class.image_regex)
        line = "#{id}\n"

        @images << Image.new(id, parts['Caption'], parts['Filename']) if parts
      end

      @body += line
    end

    raise "File `#{input_filename}` missing frontmatter" if frontmatter_bounds.positive?

    @frontmatter = YAML.safe_load(@frontmatter) || {}
    @frontmatter = @frontmatter.key?('bloggen') ? @frontmatter['bloggen'] : nil

    return unless !@frontmatter.nil? && @frontmatter.key?('feature_image')

    @images << Image.new(SecureRandom.uuid, 'Feature image', @frontmatter['feature_image'])
  end

  def publish(processor, context)
    context.logger.write(@title, "✅ Publishing '#{@title}'")

    processor.process(self, context)

    dest = "#{context.dest_dir}/_#{type}s/#{filename}.md"
    File.open(dest, 'w') { |f| f.write("#{content}\n") }
    context.logger.write_verbose(@title, "Writing content to '#{dest}'")

    return unless @images.count.positive?

    context.logger.write_verbose(@title, 'Writing images')
    context.logger.indent(@title, 2)
    @images.each do |i|
      filename = i.contextual_filename(context)
      fname = "#{context.dest_dir}/assets/posts/#{filename}"
      sname = "#{context.images_source_dir}/#{filename}"

      unless File.exist?(sname)
        context.logger.write_verbose(@title, "❓ Image '#{filename}' not found")
        next
      end

      context.logger.write_verbose(@title, "✅ Writing '#{filename}'")
      FileUtils.mkdir_p(File.dirname(fname))
      FileUtils.cp(sname, fname)
    end
    context.logger.indent(@title, -2)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
end

# rubocop:enable Metrics/ClassLength
