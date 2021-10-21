# frozen_string_literal: true

# Update Wikilinks to Markdown links
class WikilinkProcessor
  def process(post, context)
    logid = post.title
    context.logger.write_verbose(logid, 'Processing links')
    context.logger.indent(logid, 2)

    convert_wikilinks_to_md(post, context)
    strip_unresolved_links_with_display(post, context, logid)
    strip_unresolved_links_without_display(post, context, logid)

    context.logger.indent(logid, -2)
  end

  private

  def convert_wikilinks_to_md(post, context)
    context.posts.each do |other_post|
      link = post == other_post ? '#' : other_post.permalink
      title = other_post.published? ? other_post.title : "_Coming soon: #{other_post.title}_"

      post.body = post.body.gsub(/\[\[#{other_post.title}\]\]/) do
        "[#{title}](#{link})"
      end

      post.body = post.body.gsub(/\[\[#{title}\|([^\]]+)\]\]/) do
        "[#{Regexp.last_match(1)}](#{link})"
      end
    end
  end

  def strip_unresolved_links_with_display(post, context, logid)
    post.body = post.body.gsub(/\[\[([^|\]]+)\|([^\]]+)\]\]/) do
      context.logger.write_verbose(
        logid,
        "❌ Removing link to '#{Regexp.last_match(1)}', text: '#{Regexp.last_match(2)}'"
      )
      Regexp.last_match(2)
    end
  end

  def strip_unresolved_links_without_display(post, context, logid)
    post.body = post.body.gsub(/\[\[([^\]]+)\]\]/) do
      context.logger.write_verbose(logid, "❌ Removing link to '#{Regexp.last_match(1)}'")
      Regexp.last_match(1).to_s
    end
  end
end
