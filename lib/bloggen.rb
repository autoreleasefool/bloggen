# frozen_string_literal: true

require_relative 'logger/logger'
require_relative 'markdown_processor/markdown_processor'
require_relative 'posts/posts'
require_relative 'tags/tags'
require 'fileutils'

class Bloggen

  def initialize(blogname, posts_source, images_source, tags_file, dest)
    @blogname = blogname
    @posts_source_dir = posts_source
    @images_source_dir = images_source
    @tags_file = tags_file
    @dest_dir = dest

    @logger = Logger.new
  end

  def verbose=(verbose)
    @logger.verbose = verbose
  end

  def terse=(terse)
    @logger.terse = terse
  end

  def generate

    posts = Posts::collect(@blogname, @posts_source_dir)
    tags = Tags::collect(@tags_file).sort_by(&:slug)

    processor = MarkdownProcessor.new()
    context = ProcessorContext.new(
      @blogname,
      posts,
      tags,
      @images_source_dir,
      @logger,
    )

    # Remove existing posts
    Posts::clean(@dest_dir)

    posts
      .each { |post| logger.create_context(post.title, "[POST] #{post.title}") }
      .select { |post| post.is_published }
      .each { |post|
        logid = post.title
        @logger.write(logid, "✅ Publishing '#{post.title}'")

        processor.process(post, context)

        dest = "#{@dest_dir}/_#{post.type}s/#{post.filename}.md"
        File.open(dest, 'w') do |file|
          file.write(post.content)
          file.write("\n")
        end
        @logger.verbose(logid, "Writing content to '#{dest}'")

        if post.images.count > 0 then
          @logger.verbose(logid, "Writing images")
          @logger.indent(logid, 2)
          post.images.each do |i|
            fname = "#{@dest_dir}/assets/posts/#{i.filename}"
            sname = "#{@images_source_dir}/#{i.filename}"

            if !File.exist?(sname) then
              @logger.verbose(logid, "❓ Image '#{i.filename}' not found")
              next
            end

            @logger.verbose(logid, "✅ Writing '#{i.filename}'")
            FileUtils.mkdir_p(File.dirname(fname))
            FileUtils.cp(sname, fname)
          end
          @logger.indent(logid, -2)
        end
      }

    posts
      .select { |post| !post.is_published }
      .each { |post| @logger.write_e(post.title, "❌ Not publishing '#{post.title}'") }

    # Clean up tags directories
    Tags::clean(@dest_dir)

    # Publish each tags that's valid
    tags
      .each { |tag| @logger.create_context(tag.slug, "[TAGS] #{tag.slug}")}
      .each { |tag|
        tag_file = "#{@dest_dir}/_data/tags.yml"
        File.open(tag_file, "a") do |f|
          f.write("- name: #{tag.name}\n  slug: #{tag.slug}\n")
          if tag.image_path != nil
            f.write("  has_image: true\n")
          end
        end
        @logger.write_e(tag.slug, "✅ Appending to '#{tag_file}'")

        tag_html = "#{@dest_dir}/tags/#{tag.slug}.html"
        File.open(tag_html, "w") do |f|
          f.write("---\n")
          f.write("layout: tag\n")
          f.write("tag: #{tag.slug}\n")
          f.write("permalink: /tags/#{tag.slug}\n")
          f.write("---\n")
        end
        @logger.write_e(tag.slug, "✅ HTML to '#{tag_html}'")

        next unless tag.image_path != nil

        fname = File.basename(tag.image_path)
        image_dest = "#{@dest_dir}/assets/tags/#{fname}"

        FileUtils.cp(
          "#{@images_source_dir}/#{tag.image_path}",
          image_dest
        )

        @logger.write_e(tag.slug, "✅ Writing image to '#{image_dest}")
      }

    @logger.flush
  end

end
