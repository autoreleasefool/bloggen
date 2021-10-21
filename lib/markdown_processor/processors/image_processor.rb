# frozen_string_literal: true

# Update image links
class ImageProcessor
  def process(post, context)
    return unless post.images.count.positive?

    logid = post.title
    context.logger.write_verbose(logid, 'Processing images')
    context.logger.indent(logid, 2)

    post.images.each { |i| process_post(post, context, i, logid) }

    context.logger.indent(logid, -2)
  end

  private

  def process_post(post, context, image, logid)
    post.body = post.body.gsub(
      image.id.to_s,
      "![#{image.caption}](/assets/posts/#{image.filename})\n\n<figcaption>#{image.caption}</figcaption>"
    )

    context.logger.write_verbose(logid, "Processed '#{image.filename}'")
  end
end
