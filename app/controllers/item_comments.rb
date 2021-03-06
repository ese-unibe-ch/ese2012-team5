class ItemComments < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
    @current_user = @database.user_by_name(session[:name])
  end

  # Takes care of adding a comment to an item.
  post '/item/:id/comments' do
    current_item = @database.item_by_id(params[:id].to_i)
    new_comment = params[:comment]

    session[:message] = ""
    session[:message] += Validator.validate_string(new_comment, "comment")
    if session[:message] != ""
      redirect "/item/#{current_item.id}"
    end

    current_item.add_comment(Time.now, new_comment, @current_user)

    session[:message] = "~note~added new comment to item"
    redirect "/item/#{current_item.id}"
  end

  # Takes care of deleting a comment.
  post '/item/:id/delete_comment' do
    current_item = @database.item_by_id(params[:id].to_i)

    current_item.delete_comment(params[:timestamp])

    session[:message] = "~note~comment deleted"
    redirect "/item/#{current_item.id}"
  end

end