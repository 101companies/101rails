class MessagesController < ApplicationController

  def last_received
    user = current_user
    user.last_message_id = params[:last_message_id]
    user.save!
  end

end
