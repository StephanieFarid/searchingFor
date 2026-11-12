# Full-text search over items, backed by Typesense.
#
# The "items" collection mirrors each Item. It is kept in sync by ItemIndexJob; rebuild it from
# scratch with `bin/rails typesense:reindex`.
module ItemSearch
  COLLECTION = "items".freeze
  PER_PAGE = 25

  # Errors that mean "Typesense is unavailable", so callers can fall back.
  UNAVAILABLE = [ Typesense::Error, Faraday::Error, SystemCallError ].freeze

  # Sentinels let us HTML-escape user content, then turn these into <mark>.
  MARK_OPEN = "\u0001"
  MARK_CLOSE = "\u0002"

  SCHEMA = {
    name: COLLECTION,
    fields: [
      { name: "title", type: "string" },
      { name: "description", type: "string", optional: true },
      { name: "created_at", type: "int64" }
    ],
    default_sorting_field: "created_at"
  }.freeze

  Result = Data.define(:items, :found, :highlights)

  mattr_accessor :client

  class << self
    def search(query, page: 1)
      response = documents.search(
        q: query,
        query_by: "title,description",
        query_by_weights: "2,1",
        sort_by: "_text_match:desc,created_at:desc",
        highlight_fields: "title",
        highlight_start_tag: MARK_OPEN,
        highlight_end_tag: MARK_CLOSE,
        per_page: PER_PAGE,
        page: page
      )

      hits = response["hits"]
      ids = hits.map { |hit| hit.dig("document", "id").to_i }
      items = Item.where(id: ids).index_by(&:id).values_at(*ids).compact
      highlights = hits.to_h do |hit|
        [ hit.dig("document", "id").to_i, hit["highlights"]&.find { |h| h["field"] == "title" }&.dig("snippet") ]
      end.compact

      Result.new(items:, found: response["found"], highlights:)
    end

    def index(item)
      documents.upsert(document_for(item))
    end

    def remove(item_id)
      documents[item_id.to_s].delete
    rescue Typesense::Error::ObjectNotFound
      # Already gone.
    end

    def reindex_all!
      begin
        client.collections[COLLECTION].delete
      rescue Typesense::Error::ObjectNotFound
      end
      client.collections.create(SCHEMA)

      Item.find_in_batches(batch_size: 500) do |batch|
        results = documents.import(batch.map { |item| document_for(item) }, action: "upsert")
        failures = results.reject { |r| r["success"] }
        raise "Typesense import failed: #{failures.first(3).inspect}" if failures.any?
      end
    end

    # Turns a Typesense snippet into safe HTML with <mark> around matches.
    def highlight_html(snippet)
      ERB::Util.html_escape(snippet)
        .gsub(MARK_OPEN, "<mark>").gsub(MARK_CLOSE, "</mark>")
        .html_safe
    end

    private
      def documents
        client.collections[COLLECTION].documents
      end

      def document_for(item)
        {
          id: item.id.to_s,
          title: item.title,
          description: item.description.to_s,
          created_at: item.created_at.to_i
        }
      end
  end
end
