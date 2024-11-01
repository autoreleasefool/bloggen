# frozen_string_literal: true

# Process comments
class CommentsProcessor
  def process(post, context)
    context.logger.write_verbose(post.title, 'Processing comments')

    post.body.gsub(/<!--.*?-->/m, '')
  end
end
