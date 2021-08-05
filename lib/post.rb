# frozen_string_literal: true

class Post

  attr_accessor :frontmatter

  @@image_regex = /^!\[(?<Caption>[^\]]+)\]\((?<Filename>[^\)]+)\)/

  def initialize(input_filename)
    @title = File.basename(input_filename, '.md')
    @frontmatter = {}
    @body = ''

    in_frontmatter = false
    File.foreach(input_filename) do |line|
      if line.strip == '---' then
        in_frontmatter = !in_frontmatter
        next
      end

      if in_frontmatter then
        key, value = line.split(':', 2)
        next unless key.start_with?('bloggen_')

        @frontmatter[key[8...]] = value.strip
      else
        @body = "#{@body}#{line}"
      end
    end
  end

  def publish(dest_dir)
    dest = "#{dest_dir}/_#{type}s/#{filename}.md"
    body_out = "\n" + @body.each_line
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

  private

  def type
    @frontmatter["type"]
  end

  def filename
    "#{@frontmatter["date"][0..9]}-#{@frontmatter["permalink"]}"
  end

  def tags
    @frontmatter["tags"].split(", ").join(' ')
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
      "title: \"#{@title}\"",
      "date: #{@frontmatter["date"]}",
      feature_image ? feature_image : nil,
      "tags: #{tags}",
      '---',
    ].compact.join("\n")
  end

end