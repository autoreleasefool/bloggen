# bloggen

Generate blog posts from particularly formatted Markdown

See my blog at [https://runcode.blog](https://runcode.blog) for an example published by this script.

## Usage

- `./bin/bloggen <blogname> <posts_source> <images_source> <tags_file> <destination>`
- `./bin/publish_runcode`

## Posts

### Frontmatter

Posts require particularly formatted frontmatter, and should be written in markdown.

The following frontmatter is supported. You can include other frontmatter, and it won't be consumed by bloggen, or published to your blog. All of the frontmatter should appear underneath a `bloggen:` top level key:

| Key             | Required?          | Description                                                    |
| --------------- | ------------------ | -------------------------------------------------------------- |
| `blog`          | :white_check_mark: | Name of the blog under which this post should be published     |
| `tags`          | :white_check_mark: | YAML list of tags for the post                                 |
| `publish`       | :white_check_mark: | `true` or `false` to indicate if this post is ready to publish |
| `type`          | :white_check_mark: | `post` is the only valid value                                 |
| `permalink`     | :white_check_mark: | Slug for the post                                              |
| `date`          | :white_check_mark: | Date on which the post was first published                     |
| `feature_image` | :x:                | Feature image for the post                                     |

An example of a post with valid frontmatter:

```
---
bloggen:
  blog: runcode.blog
  publish: true
  type: post
  permalink: test-post-please-ignore
  date: 2021-08-05
  tags:
    - list
    - of
    - tags
unrelated_frontmatter: true
---

# This is the title

Here's an introduction.

## This is a secondary header

Here's another line.
```

### Post content

Posts should be written in markdown, and expect the following approximate format:

- All lines leading up to the first H1 header tag (in markdown, a single `#`) will be ignored. This is a great place for taking notes related to your post
- The first H1 header tag (a single `#`) will be used as the title of the blog post
- Only a single H1 header tag (a single `#`) should appear per blog post
- You can use most markdown elements as expected.
- Images must appear on their own line, with the following format: `![Caption](filename_in_images_source)`
- The filename should end in a `.md` file extension
- You can include HTML style comments (`<!-- This is a comment -->`) and they will be stripped from the post before publishing.

### Output

bloggen has been built to support publishing to a blog backed by [jekyll](https://jekyllrb.com). It will output posts to a `_posts` subdirectory in the `<destination>` provided in the arguments, and will output images to a `assets/posts/` subdirectory in `<destination>`. It will also clean these folders before writing changes, so if you're just starting with bloggen, ensure your posts are backed up elsewhere.

## Tags

bloggen will capture and publish your tags, from a file formatted as follows:

```
- name: tag_name
  slug: tag-slug
  feature_image: path/to/image.jpg
```

### Output

bloggen will create a file `_data/tags.yml` with your tags, their slugs, and their images in `<destination>`. It will also create a separate `tags/slug-name.html` for each tag. It will also output images to a `assets/tags/` subdirectory in `<destination>`. Finally, it will clean these folders before writing changes, so if you're just starting with bloggen, ensure your posts are backed up elsewhere.
