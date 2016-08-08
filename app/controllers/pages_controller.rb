class PagesController < ApplicationController

  include RdfModule

  # for calling from view
  helper_method :get_rdf_json

  respond_to :json, :html

  # before_filter need to be before load_and_authorize_resource
  # methods, that need to check permissions
  before_filter :get_the_page, only: [:edit, :rename, :update, :update_repo, :destroy]
  authorize_resource only: [:delete, :rename, :update, :apply_findings, :update_repo]

  def get_the_page
    full_title = params[:id]

    @page = GetPage.run(full_title: full_title).value[:page]
    # if page doesn't exist, but it's user page -> create page and redirect
    if @page.nil? && !current_user.nil? && full_title.downcase=="Contributor:#{current_user.github_name}".downcase
      PageModule.create_page_by_full_title(full_title)
      redirect_to "/wiki/#{full_title}" and return
    end
    # page not found and user can create page -> create new page by full_title
    if @page.nil? && (can? :create, Page.new)
      redirect_to create_new_page_confirmation_page_path(full_title)
      return
    end
    # if no page created/found
    if !@page
      return respond_to do |format|
        format.html do
          flash[:error] = "Page wasn't not found. Redirected to main wiki page"
          go_to_homepage
        end
        format.json {
          return render json: {success: false}, status: 404
        }
      end
    end

    # get rdf
    @rdf = get_rdf_json(@page.full_title, true)

    @rdf = @rdf.sort do |x,y|
      if x[:predicate] == y[:predicate]
        x[:node] <=> y[:node]
      else
        x[:predicate] <=> y[:predicate]
      end
    end

    @resources = @rdf.select do |triple|
      (triple[:node].start_with?('http://') || triple[:node].starts_with?('https://'))
    end

    @rdf = @rdf.select do |triple|
      !(triple[:node].start_with?('http://') || triple[:node].start_with?('https://'))
    end

    @books = []
  end

  def render_script
    path = Dir.entries(Rails.root.join('public/assets')).select do |entry|
      entry.starts_with?('application') && entry.ends_with?('.css')
    end.first

    path = Rails.root.join('public/assets', path)

    js_path = Dir.entries(Rails.root.join('public/assets')).select do |entry|
      entry.starts_with?('application') && entry.ends_with?('.js')
    end.first

    js_path = Rails.root.join('public/assets', js_path)

    page = Page.find(params[:id])
    links = page.raw_content.scan(/\[\[([^\]]+)\]\]/).select do |link|
      !link[0].include?('::')
    end

    pages = [page] + links.map do |link|
      GetPage.run(full_title: link[0]).value[:page]
    end.select do |page|
      !page.nil?
    end

    outputs = pages.map do |page|
      render_page(page)
    end

    page_refs = pages.map do |page|
      {
        id: page.id.to_s,
        full_title: page.full_title
      }
    end

    result = outputs.join("\n")
    result = "<html>
    <head>
      <meta charset=\"UTF-8\">
      <style>
        #{contents = File.read(path)}
      </style>
      <script type='text/javascript'>
        #{contents = File.read(js_path)}
        window.links = #{page_refs.to_json};
      </script>

      <style type='text/css'>
        .section-content-container {
          padding-bottom: 20px;
        }

        hr {
          border-color: black;
        }
      </style>

      <script>
        $(document).ready(function() {
            var internal_links = $('a').filter(function(index) {
              var href = $(this).attr('href');
              if(!href) {
                return false;
              }
              return href.indexOf('/wiki/') === 0 || href.indexOf('wiki/../') === 0;
            });

          internal_links.each(function(index, value) {
            var $value = $(value);
            var href = $value.attr('href');
            if(href[0] != '/') {
              href = '/'+ href;
            }
            $value.attr('href', 'http://101companies.org' + href);
          });

          $.each(window.links, function(index, link) {
            $('a[href=\"' + 'http://101companies.org/wiki/' + link.full_title.replace('_', ' ') + '\"]').each(function(index, value) {
              var $value = $(value);
              $value.attr('href', '#' + link.id);
            });

            $('a[href=\"' + 'http://101companies.org/wiki/' + link.full_title + '\"]').each(function(index, value) {
              var $value = $(value);
              $value.attr('href', '#' + link.id);
            });
          });
        });
      </script>

    </head>
    <body>
      <div class='container'>
        #{result}
      </div>
    </body>
    </html>
    "

    File.open("#{Dir.home}/101web/data/pages/" + page.full_title + '.html', 'w') { |file| file.write(result) }

    redirect_to request.referer, notice: 'Rendered successfuly'
  end

  def render_page(page)
    rdf = GetTriplesForPage.run(page: page).value[:triples]
    rdf = rdf.select do |rdf|
      rdf[:direction] == 'OUT'
    end

    view = ActionView::Base.new(Rails.configuration.paths['app/views'], { script_render: true, rdf: rdf, page: page })
    view.extend ApplicationHelper
    view.class_eval do
      include Rails.application.routes.url_helpers
      include ApplicationHelper
      def protect_against_forgery?
        false
      end
    end


    "<div class='page' style='margin-top: 40px;'>
     #{view.render(file: 'pages/_page.html.erb')}
     </div>"
  end

  def unverify
    if (cannot? :unverify, Page)
      flash[:error] = "You don't have enough rights for that."
      go_to_homepage and return
    end

    UnverifyPage.run(user_id: current_user.id, page_id: params[:id], full_title: params[:id]).match do

      failure(:page_already_unverified) do
        flash[:error] = "Page is already unverified."
        go_to_homepage
      end

      success do
        flash[:notice] = 'Page is unverified now.'
        redirect_to(page_path(params[:id]))
      end

    end
  end

  def verify
    if (cannot? :verify, Page)
      flash[:error] = "You don't have enough rights for that."
      go_to_homepage and return
    end

    VerifyPage.run(user_id: current_user.id, page_id: params[:id], full_title: params[:id]).match do

      failure(:page_already_verified) do
        flash[:error] = "Page is already verified."
        go_to_homepage
      end

      success do
        flash[:notice] = 'Page is verified now.'
        redirect_to(page_path(params[:id]))
      end

    end

  end

  def unverified
    if (cannot? :list, :unverified_pages)
      flash[:error] = "You don't have enough rights for that."
      go_to_homepage and return
    end

    ListUnverifiedPages.run.match do

      success do |result|
        @pages = result[:pages]
      end

    end
  end

  def create_new_page
    if (cannot? :create, Page.new)
      flash[:error] = "You don't have enough rights for creating the page."
      go_to_homepage and return
    end

    full_title = params[:id]
    page = PageModule.create_page_by_full_title(full_title)
    if page
      redirect_to "/wiki/#{full_title}" and return
    else
      flash[:error] = "You cannot create new page #{full_title}"
      redirect_to "/wiki/101project" and return
    end
  end

  def create_new_page_confirmation
    @full_title = params[:id]
  end

  def update_repo
    repo_link = params[:repo_link]
    # if no link to repo -> create it
    if @page.repo_link.nil?
      @page.repo_link = RepoLink.new
    end
    # fill props
    @page.repo_link.folder = repo_link[:folder]
    @page.repo_link.user = repo_link[:user_repo].split('/').first
    @page.repo_link.repo = repo_link[:user_repo].split('/').last
    # assign page
    @page.repo_link.page = @page
    # save page and link
    (@page.save and @page.repo_link.save) ?
      flash[:success]="Updated linked repo" : flash[:error] = "Failed to update linked repo"
    redirect_to  "/wiki/#{@page.url}"
  end

  def edit
    @pages = Page.all.map &:full_title

    begin
      url = "http://worker.101companies.org/data/dumps/wiki-predicates.json"
      url = URI.encode url
      url = URI(url)

      request = Net::HTTP::Get.new url
      response = Net::HTTP.start(url.host, url.port, read_timeout: 0.5, connect_timeout: 1) {|http| http.request(request)}
      @predicates = JSON::parse(response.message)
    rescue JSON::ParserError, rrno::EHOSTUNREACH, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      @predicates = {}
      Rails.logger.warn("Predicates retrieval failed")
    end
  end

  def destroy
    authorize! :destroy, @page

    result = @page.delete
    # generate flash_message if deleting was successful
    if result
      page_change = PageChange.new title: @page.title,
                     namespace: @page.namespace,
                     raw_content: @page.raw_content,
                     page: @page,
                     user: current_user
      page_change.save
      flash[:notice] = 'Page ' + @page.full_title + ' was deleted'
    end
    render json: { success: result }
  end

  def show
    args = {
      full_title: params[:id],
      current_user: current_user
    }

    ShowPage.run(args).match do

      success do |result|
        @page           = result[:page]
        @books          = result[:books]
        @rdf            = result[:triples]
        @resources      = result[:resources]
        @contributions  = result[:contributions]
      end

      failure(:page_not_found) do |result|
        flash[:error] = "Page wasn't not found. Redirected to main wiki page"
        go_to_homepage
      end

      failure(:bad_link) do |result|
        redirect_to result[:url]
      end

      failure(:page_not_found_but_creating) do |result|
        redirect_to create_new_page_confirmation_page_path(result[:full_title])
      end

      failure(:contributor_page_created) do |result|
        redirect_to "/wiki/#{result[:full_title]}"
      end

    end

  end

  def search
    @query_string = params[:q] || ''
    if @query_string == ''
      flash[:notice] = 'Please write something, if you want to search something'
      go_to_homepage
    else
      @search_results = PageModule.search @query_string
      respond_with @search_results
    end
  end

  def rename
    new_name = PageModule.unescape_wiki_url params[:newTitle]
    result = @page.update_or_rename(new_name, @page.raw_content, [], current_user)
    render json: {
      success: result,
      newTitle: @page.url
    }
  end

  def update
    result = @page.update_or_rename(@page.full_title, params[:content], [], current_user)
    render json: {
      success: result,
      newTitle: @page.url
    }
  end

end
