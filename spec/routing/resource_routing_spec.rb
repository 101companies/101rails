require 'rails_helper'

describe ResourcesController, type: :routing do

  it "routes resources/ to resource#index" do
    expect(:get => '/resources').to route_to('resources#index')
  end

  it "routes to specified format" do
    expect(:get => '/resources/rspec.rb.json').
        to route_to(:controller => "resources",
                    :action => "show",
                    :id => "rspec.rb",
                    :format => "json")

    expect(:get => '/resources/rspec.rb.xml').
        to route_to(:controller => "resources",
                    :action => "show",
                    :id => "rspec.rb",
                    :format => "xml")

    expect(:get => '/resources/rspec.rb.ttl').
        to route_to(:controller => "resources",
                    :action => "show",
                    :id => "rspec.rb",
                    :format => "ttl")

    expect(:get => '/resources/rspec.rb.n3').
        to route_to(:controller => "resources",
                    :action => "show",
                    :id => "rspec.rb",
                    :format => "n3")
  end

  it "routes to html (default)" do
    expect(:get => '/resources/rspec.rb.html').
        to route_to(:controller => "resources",
                    :action => "show",
                    :id => "rspec.rb",
                    :format => "html")

    expect(:get => '/resources/rspec.rb').
        to route_to(:controller => "resources",
                    :action => "show",
                    :id => "rspec.rb")

    expect(:get => '/resources/rspec').
        to route_to(:controller => "resources",
                    :action => "show",
                    :id => "rspec")
  end
end
