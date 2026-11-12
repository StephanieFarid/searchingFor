class CommentsController < ApplicationController
  before_action :set_item

  def create
    @comment = @item.comments.new(comment_params.merge(user: Current.user))
    if @comment.save
      redirect_to item_path(@item, anchor: helpers.dom_id(@comment)), notice: "Comment added."
    else
      redirect_to item_path(@item), alert: @comment.errors.full_messages.to_sentence
    end
  end

  def destroy
    @item.comments.where(user: Current.user).find(params.expect(:id)).destroy!
    redirect_to item_path(@item), notice: "Comment deleted.", status: :see_other
  end

  private
    def set_item
      @item = Item.find(params.expect(:item_id))
    end

    def comment_params
      params.expect(comment: [ :body ])
    end
end
