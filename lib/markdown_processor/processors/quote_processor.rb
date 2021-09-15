# frozen_string_literal: true

class QuoteProcessor

  def process(post, context)
    context.logger.verbose(post.title, "Processing quotes")

    post.body = post.body.gsub(/‘|’/, "'")
    post.body = post.body.gsub(/“|”/, "\"")
  end

end
