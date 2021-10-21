# frozen_string_literal: true

# Standardize quotes
class QuoteProcessor
  def process(post, context)
    context.logger.write_verbose(post.title, 'Processing quotes')

    post.body = post.body.gsub(/‘|’/, "'")
    post.body = post.body.gsub(/“|”/, '"')
  end
end
