class ItemComments < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
    @current_item = @database.item_by_id(params[:id].to_i)
    @current_user = @database.user_by_name(session[:name])
  end


  post "/item/:id/comments" do
    new_comment = params[:comment]


    session[:message] = ""
    session[:message] += Helper::Validator.validate_string(new_comment, "comment")
    if session[:message] != ""
      redirect "/item/#{@current_item.id}"
    end

    time_now = Time.new
    @current_item.add_comment(time_now, new_comment, @current_user)

    session[:message] = "~note~added new comment to item"
    redirect "/item/#{@current_item.id}"
  end

  post "/item/:id/delete_comment" do
    @current_item.delete_comment(params[:timestamp])

    session[:message] = "~note~comment deleted"
    redirect "/item/#{@current_item.id}"
  end

end