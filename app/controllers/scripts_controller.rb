class ScriptsController < ApplicationController

  def show
    ShowPage.run(full_title: params[:id]).match do
      success do |result|
        @page = result[:page]
        links = @page.raw_content.scan(/\[\[([^\]]+)\]\]/).select do |link|
          !link[0].include?('::')
        end

        GetMultiplePages.run(links: links).match do
          success do |result|
            @pages = [@page] + result[:pages]
          end
        end
      end

      failure do |result|
        flash[:error] = "Page wasn't not found. Redirected to main wiki page"
        go_to_homepage
      end
    end
  end

end
