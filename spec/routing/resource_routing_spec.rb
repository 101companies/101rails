require 'rspec'

describe 'resource routing' do

  it "routes resource/ to #landing" do
    expect(:get => 'resource/').to route_to('resource#landing')
  end


  it "routes to specified format" do
    expect(:get => 'resource/rspec.rb.json').
        to route_to(:controller => "resource",
                    :action => "get",
                    :resource_name => "rspec.rb",
                    :format => "json")

    expect(:get => 'resource/rspec.rb.xml').
        to route_to(:controller => "resource",
                    :action => "get",
                    :resource_name => "rspec.rb",
                    :format => "xml")

    expect(:get => 'resource/rspec.rb.ttl').
        to route_to(:controller => "resource",
                    :action => "get",
                    :resource_name => "rspec.rb",
                    :format => "ttl")

    expect(:get => 'resource/rspec.rb.n3').
        to route_to(:controller => "resource",
                    :action => "get",
                    :resource_name => "rspec.rb",
                    :format => "n3")
  end

  it "routes to html (default) format" do
    expect(:get => 'resource/rspec.rb.html').
        to route_to(:controller => "resource",
                    :action => "get",
                    :resource_name => "rspec.rb",
                    :format => "html")

    expect(:get => 'resource/rspec.rb').
        to route_to(:controller => "resource",
                    :action => "get",
                    :resource_name => "rspec.rb")

    expect(:get => 'resource/rspec').
        to route_to(:controller => "resource",
                    :action => "get",
                    :resource_name => "rspec")
  end
end