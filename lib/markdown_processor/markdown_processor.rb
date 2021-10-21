# frozen_string_literal: true

require_relative 'processors/image_processor'
require_relative 'processors/quote_processor'
require_relative 'processors/wikilink_processor'

# Process Post Markdown
class MarkdownProcessor
  def initialize
    @subprocessors = [
      WikilinkProcessor.new,
      QuoteProcessor.new,
      ImageProcessor.new
    ]
  end

  def process(post, context)
    @subprocessors.each { |p| p.process(post, context) }

    processed_body = post.body.each_line
                         .drop(2)
                         .reject(&:empty?)
                         .join("\n")
                         .split("\n\n")
                         .join("\n")
                         .rstrip

    post.body = "\n\n#{processed_body}"
  end
end
