class ScriptsController < ApplicationController

  def show
    GetPage.run(full_title: params[:id]).match do
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
    end
  end

end
