class StartNodePresenter < NodePresenter
  def initialize(i18n_prefix, node, state = nil, options = {})
    super(i18n_prefix, node, state)
    @renderer = options[:renderer] || SmartAnswer::ErbRenderer.new(
      template_directory: @node.template_directory,
      template_name: @node.name.to_s
    )
  end

  def title
    title = @renderer.content_for(:title, html: false)
    title.present? ? title.chomp : super
  end

  def has_meta_description?
    !!meta_description
  end

  def meta_description
    meta_description = @renderer.content_for(:meta_description, html: false)
    meta_description && meta_description.chomp
  end

  def body(html: true)
    @renderer.content_for(:body, html: html)
  end

  def has_post_body?
    !!post_body
  end

  def post_body(html: true)
    @renderer.content_for(:post_body, html: html)
  end
end
