# frozen_string_literal: true

class WikilinkProcessor

  def process(post, context)
    logid = post.title
    context.logger.verbose(logid, "Processing links")
    context.logger.indent(logid, 2)

    context.posts.each do |other_post|
      link = post == other_post ? "#" : other_post.permalink
      title = other_post.is_published ? other_post.title : "_Coming soon: #{other_post.title}_"

      post.body = post.body.gsub(/\[\[#{other_post.title}\]\]/) do
        context.logger.verbose(logid, "✅ Processed link to '#{title}'")
        "[#{title}](#{link})"
      end

      # post.body = post.body.gsub(
      #   /\[\[#{other_post.title}\]\]/,
      #   "[#{title}](#{link})"
      # )

      post.body = post.body.gsub(/\[\[#{title}\|([^\]]+)\]\]/) do
        context.logger.verbose(logid, "✅ Processed link to '#{title}', text: '#{$1}'")
        "[#{$1}](#{link})"
      end

      # post.body = post.body.gsub(
      #   /\[\[#{title}\|([^\]]+)\]\]/,
      #   "[\\1](/posts/#{link})"
      # )

      # if post.body != initial_body then
      #   context.logger.verbose(logid, "Processed link to '#{title}'")
      # end
    end

    post.body = post.body.gsub(/\[\[([^\|\]]+)\|([^\]]+)\]\]/) do
      context.logger.verbose(logid, "❌ Removing link to '#{$1}', text: '#{$2}'")
      "#{$2}"
    end

    # post.body = post.body.gsub(
    #   /\[\[[^\|\]]+\|([^\]]+)\]\]/,
    #   "\\1"
    # )

    post.body = post.body.gsub(/\[\[([^\]]+)\]\]/) do
      context.logger.verbose(logid, "❌ Removing link to '#{$1}'")
      "#{$1}"
    end

    # post.body = post.body.gsub(
    #   /\[\[([^\]]+)\]\]/,
    #   "\\1"
    # )

    context.logger.indent(logid, -2)
  end

end
