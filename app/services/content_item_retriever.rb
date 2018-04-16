class ContentItemRetriever
  def self.fetch(slug)
    Services.content_store.content_item("/#{slug}")
      .to_hash.with_indifferent_access

  rescue GdsApi::HTTPNotFound, GdsApi::HTTPGone
    {}
  end
end
