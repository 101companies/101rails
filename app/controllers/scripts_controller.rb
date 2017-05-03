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
            @triples = {}

            @pages.each do |page|
              GetTriplesForPage.run(page: page).match do
                success do |result|
                  @triples[page] = result[:triples]
                end
              end
            end
          end
        end
      end

      failure do |result|
        flash[:error] = "Page wasn't not found. Redirected to main wiki page"
        go_to_homepage
      end
    end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "file_name"
      end
    end
  end

end
