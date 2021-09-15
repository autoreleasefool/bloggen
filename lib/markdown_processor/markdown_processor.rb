# frozen_string_literal: true

require_relative 'processors/image_processor'
require_relative 'processors/quote_processor'
require_relative 'processors/wikilink_processor'

ProcessorContext = Struct.new(
  :blogname,
  :posts,
  :tags,
  :images_source_dir,
  :logger,
)

class MarkdownProcessor

  def initialize()
    @subprocessors = [
      WikilinkProcessor.new(),
      QuoteProcessor.new(),
      ImageProcessor.new(),
    ]
  end

  def process(post, context)
    @subprocessors.each do |processor|
      processor.process(post, context)
    end

    post.body = "\n\n" + post.body.each_line
      .drop(2)
      .select { |l| !l.empty? }
      .join("\n")
      .split("\n\n")
      .join("\n")
      .rstrip
  end

end
