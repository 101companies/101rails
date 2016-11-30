class RenderPageJob < ApplicationJob
  queue_as :default

  def perform(id, user_id)
    ap user_id
    ap id
    path = Dir.entries(Rails.root.join('public/assets')).select do |entry|
      entry.starts_with?('application') && entry.ends_with?('.css')
    end.first

    path = Rails.root.join('public/assets', path)

    js_path = Dir.entries(Rails.root.join('public/assets')).select do |entry|
      entry.starts_with?('application') && entry.ends_with?('.js')
    end.first

    js_path = Rails.root.join('public/assets', js_path)

    page = Page.find(id)
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

    MessageBus.publish('/messages', 'Page rendering done', user_ids: [user_id])
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
end
