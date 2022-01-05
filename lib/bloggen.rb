# frozen_string_literal: true

require_relative 'logger/logger'
require_relative 'markdown_processor/markdown_processor'
require_relative 'posts/posts'
require_relative 'tags/tags'
require 'fileutils'

Context = Struct.new(
  :blogname,
  :posts,
  :tags,
  :images_source_dir,
  :dest_dir,
  :logger,
  :strip_absolute_paths
) do
  def scheduled_posts
    posts.select { |post| post.published? && !post.after_publish_date? }
  end

  def unpublished_posts
    posts.reject(&:published?)
  end

  def published_posts
    posts.select { |post| post.published? && post.after_publish_date? }
  end
end

# Blog generator tool
class Bloggen
  def initialize(blogname, posts_source_dir, images_source, tags_file, dest)
    posts = Posts.collect(blogname, posts_source_dir)
    tags = Tags.collect(tags_file).sort_by(&:slug)

    @processor = MarkdownProcessor.new
    @context = Context.new(blogname, posts, tags, images_source, dest, Logger.new, false)
  end

  def verbose=(verbose)
    @context.logger.verbose = verbose
  end

  def terse=(terse)
    @context.logger.terse = terse
  end

  def strip_absolute_paths=(strip_absolute_paths)
    @context.strip_absolute_paths = strip_absolute_paths
  end

  def generate
    @context.logger.reset

    setup_logger_contexts
    generate_posts
    generate_tags

    @context.logger.flush
  end

  private

  def setup_logger_contexts
    @context.tags.each { |tag| @context.logger.create_context(tag.slug, "[TAGS] #{tag.slug}") }
    @context.posts.each { |post| @context.logger.create_context(post.title, "[POST] #{post.title}") }
  end

  # Posts

  def generate_posts
    # Remove existing posts
    Posts.clean(@context.dest_dir)

    @context.scheduled_posts.each { |p| handle_scheduled_post(p) }
    @context.unpublished_posts.each { |p| handle_unpublished_post(p) }
    @context.published_posts.each { |p| handle_published_post(p) }
  end

  def handle_scheduled_post(post)
    @context.logger.write(post.title, "🕓 Waiting to publish until #{post.publish_date}")
  end

  def handle_unpublished_post(post)
    @context.logger.write_e(post.title, "❌ Not publishing '#{post.title}'")
  end

  def handle_published_post(post)
    post.publish(@processor, @context)
  end

  # Tags

  def generate_tags
    # Clean up tags directories
    Tags.clean(@context.dest_dir)

    # Publish each tags that's valid
    @context.tags
            .each do |tag|
              append_tag_to_tags(tag)
              write_tag_html(tag)
              write_tag_image(tag) unless tag.image_path.nil?
            end
  end

  def append_tag_to_tags(tag)
    tag_file = "#{@context.dest_dir}/_data/tags.yml"
    File.open(tag_file, 'a') do |f|
      f.write("- name: #{tag.name}\n  slug: #{tag.slug}\n")
      f.write("  has_image: true\n") unless tag.image_path.nil?
    end
    @context.logger.write_e(tag.slug, "✅ Appending to '#{tag_file}'")
  end

  def write_tag_html(tag)
    tag_html = "#{@context.dest_dir}/tags/#{tag.slug}.html"
    File.open(tag_html, 'w') do |f|
      f.write("---\n")
      f.write("layout: tag\n")
      f.write("tag: #{tag.slug}\n")
      f.write("permalink: /tags/#{tag.slug}\n")
      f.write("---\n")
    end
    @context.logger.write_e(tag.slug, "✅ HTML to '#{tag_html}'")
  end

  def write_tag_image(tag)
    fname = File.basename(tag.image_path)
    image_dest = "#{@context.dest_dir}/assets/tags/#{fname}"

    FileUtils.cp(
      "#{@context.images_source_dir}/#{tag.image_path}",
      image_dest
    )

    @context.logger.write_e(tag.slug, "✅ Writing image to '#{image_dest}")
  end
end
