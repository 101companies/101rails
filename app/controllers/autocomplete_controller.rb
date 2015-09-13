class AutocompleteController < ApplicationController

  def index
    prefix = params[:prefix]
    @namespace, @title = prefix.split '::'

    if @title
      @title = @title.gsub(/[^a-zA-Z0-9_]/, '')
      render json: Page.where(namespace: @namespace, title: /^#{@title}/i).pluck(:title)
    else
      render json: Page.where(namespace: @namespace).pluck(:title)
    end

  end
end
