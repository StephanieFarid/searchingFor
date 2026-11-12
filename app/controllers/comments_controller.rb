class CommentsController < ApplicationController
  rate_limit to: 10, within: 5.minutes, only: :create,
    with: -> { redirect_back_or_to root_path, alert: "You're commenting too fast. Try again in a few minutes." }

  def create
    item = Item.find(params.expect(:item_id))
    comment = item.comments.new(params.expect(comment: [ :body ]))
    if comment.save
      redirect_to item_path(item, anchor: helpers.dom_id(comment)), notice: "Comment added."
    else
      redirect_to item_path(item), alert: comment.errors.full_messages.to_sentence
    end
  end
end
