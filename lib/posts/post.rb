# frozen_string_literal: true

class Post

  attr_accessor :frontmatter

  @@image_regex = /^!\[(?<Caption>[^\]]+)\]\((?<Filename>[^\)]+)\)/

  def initialize(input_filename)
    @input_filename = input_filename
    @frontmatter = {}

    File.foreach(input_filename).with_index do |line, index|
      if index == 0 then
        if line.chomp != '---' then
          raise "File `#{input_filename}` missing frontmatter"
        end
        next
      end

      return unless line.chomp != '---'

      key, value = line.split(':', 2)
      next unless key.start_with?('bloggen_')

      @frontmatter[key[8...]] = value.strip
    end
  end

  def publish(dest_dir)
    dest = "#{dest_dir}/_#{type}s/#{filename}.md"
    body_out = "\n\n" + body.each_line
      .drop(2)
      .select { |l| !l.empty? }
      .flat_map { |l|
        if l.start_with?('![') then
          parts = l.match(@@image_regex)
          caption = parts["Caption"]
          image_filename = parts["Filename"][parts["Filename"].rindex("/") + 1..]
          [
            "![#{caption}](/assets#{permalink}/#{image_filename})",
            "\n",
            "<figcaption>#{caption}</figcaption>\n",
          ]
        else
          [l]
        end
      }
      .join("\n")
      .split("\n\n")
      .join("\n")
      .rstrip

    File.open(dest, 'w') do |file|
      file.write(formatted_frontmatter)
      file.write(body_out)
      file.write("\n")
    end
  end

  def publish_images(source_dir, dest_dir)
    collect_images.each do |i|
      fname = "#{dest_dir}/#{i}"
      FileUtils.mkdir_p(File.dirname(fname))
      FileUtils.cp(
        "#{source_dir}/#{i}",
        fname
      )
    end
  end

  def collect_images
    [
      @frontmatter.key?('feature_image') ? "#{@frontmatter["permalink"]}/#{@frontmatter["feature_image"]}" : nil
    ].compact + body.each_line
      .select { |l| l.start_with?('![') }
      .map { |l|
        parts = l.match(@@image_regex)
        fname = parts["Filename"]
        slash_index = fname.rindex("/")
        slash_index = fname.rindex("/", slash_index - fname.length - 1)

        fname[slash_index + 1..]
      }
  end

  private

  def title
    frontmatter_markers = 2
    File.foreach(@input_filename) do |line|
      frontmatter_markers -= line.chomp === '---' ? 1 : 0
      next unless frontmatter_markers <= 0

      return line[1..].strip if line.start_with?('# ')
    end
  end

  def body
    frontmatter_markers = 2
    after_title = false
    body = ""
    File.foreach(@input_filename) do |line|
      frontmatter_markers -= line.chomp === '---' ? 1 : 0
      next unless frontmatter_markers <= 0

      after_title = after_title || line.start_with?('# ')
      next unless after_title

      body = "#{body}#{line}"
    end

    body
  end

  def type
    @frontmatter["type"]
  end

  def filename
    "#{@frontmatter["date"][0..9]}-#{@frontmatter["permalink"]}"
  end

  def tags
    @frontmatter["tags"].split(",")
      .map { |t| t.strip }
      .join(' ')
  end

  def feature_image
    @frontmatter.key?('feature_image') ? "feature_image: /assets#{permalink}/#{@frontmatter["feature_image"]}" : nil
  end

  def permalink
    "/#{type}s/#{@frontmatter["permalink"]}"
  end

  def formatted_frontmatter
    [
      '---',
      "layout: #{type}",
      "permalink: #{permalink}",
      "title: \"#{title}\"",
      "date: #{@frontmatter["date"]}",
      feature_image ? feature_image : nil,
      "tags: #{tags}",
      '---',
    ].compact.join("\n")
  end

end