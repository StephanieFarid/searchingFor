# Minimal stand-in for Typesense::Client, covering the calls ItemSearch makes.
class FakeTypesense
  attr_reader :documents, :search_response
  attr_accessor :error

  def initialize
    @documents = {}
    @search_response = { "found" => 0, "hits" => [] }
  end

  # Make the next search return these items (in order), with optional title snippets.
  def returns(items, snippets: {})
    @search_response = {
      "found" => items.size,
      "hits" => items.map do |item|
        hit = { "document" => { "id" => item.id.to_s } }
        hit["highlights"] = [ { "field" => "title", "snippet" => snippets[item] } ] if snippets[item]
        hit
      end
    }
  end

  def collections = Collections.new(self)

  class Collections
    def initialize(fake) = @fake = fake
    def [](_name) = Collection.new(@fake)
  end

  class Collection
    def initialize(fake) = @fake = fake
    def documents = Documents.new(@fake)
  end

  class Documents
    def initialize(fake) = @fake = fake

    def search(params)
      raise @fake.error if @fake.error
      @fake.search_response
    end

    def upsert(doc) = @fake.documents[doc[:id]] = doc
    def [](id) = Document.new(@fake, id)
  end

  class Document
    def initialize(fake, id) = (@fake, @id = fake, id)
    def delete = @fake.documents.delete(@id) || raise(Typesense::Error::ObjectNotFound, "not found")
  end
end
