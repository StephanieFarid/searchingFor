class ItemsController < ApplicationController
  rate_limit to: 5, within: 10.minutes, only: :create,
    with: -> { redirect_back_or_to root_path, alert: "You're posting too fast. Try again in a few minutes." }

  def index
    @query = params[:q].to_s.strip
    @highlights = {}

    if @query.blank?
      @items = Item.order(created_at: :desc)
    else
      begin
        result = ItemSearch.search(@query)
        @items, @highlights = result.items, result.highlights
      rescue *ItemSearch::UNAVAILABLE => e
        Rails.logger.warn("Typesense unavailable, using SQL search: #{e.class}: #{e.message}")
        @items = Item.search(@query).order(created_at: :desc)
      end
    end
  end

  def show
    @item = Item.includes(:comments).find(params.expect(:id))
    @comment = Comment.new
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to @item, notice: "Your post is up."
    else
      redirect_back_or_to root_path, alert: @item.errors.full_messages.to_sentence
    end
  end

  private
    def item_params
      params.expect(item: [ :title, :description ])
    end
end
