# frozen_string_literal: true

class ImageProcessor

  def process(post, context)
    return unless post.images.count > 0

    logid = post.title
    context.logger.verbose(logid, "Processing images")
    context.logger.indent(logid, 2)

    post.images.each do |i|
      post.body = post.body.gsub(
        "#{i.id}",
        "![#{i.caption}](/assets/posts/#{i.filename})\n\n<figcaption>#{i.caption}</figcaption>"
      )

      context.logger.verbose(logid, "Processed '#{i.filename}'")
    end

    context.logger.indent(logid, -2)
  end

end
