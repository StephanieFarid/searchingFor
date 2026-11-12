class ItemsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :resume_session, only: %i[index show]
  before_action :set_item, only: %i[show]
  before_action :set_own_item, only: %i[edit update destroy]

  def index
    @query = params[:q].to_s.strip
    @items = Item.search(@query).includes(:user).order(created_at: :desc)
  end

  def show
    @comment = Comment.new
  end

  def new
    @item = Item.new
  end

  def edit
  end

  def create
    @item = Current.user.items.new(item_params)
    if @item.save
      redirect_to @item, notice: "Your search was posted."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @item.update(item_params)
      redirect_to @item, notice: "Item updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @item.destroy!
    redirect_to items_path, notice: "Item deleted.", status: :see_other
  end

  private
    def set_item
      @item = Item.includes(comments: :user).find(params.expect(:id))
    end

    def set_own_item
      @item = Current.user.items.find(params.expect(:id))
    end

    def item_params
      params.expect(item: [ :title, :description ])
    end
end
