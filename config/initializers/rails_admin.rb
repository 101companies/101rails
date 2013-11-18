# RailsAdmin config file. Generated on February 25, 2013 20:47
# See github.com/sferik/rails_admin for more informations

# real timezone for rails_admin
module RailsAdmin
  module Config
    module Fields
      module Types
        class Datetime
          def value
            bindings[:object].send(name)
          end
        end
      end
    end
  end
end

RailsAdmin.config do |config|

  ################  Global configuration  ################

  # Set the admin name here (optional second array element will appear in red). For example:
  config.main_app_name = ['101Wiki', 'Admin']

  # RailsAdmin may need a way to know who the current user is]
  config.current_user_method { current_user } # auto-generated

  # use roles system for blocking admin interface
  config.authorize_with :cancan

  # Number of default rows per-page:
  config.default_items_per_page = 30

  config.model 'OldWikiUser' do

    field :email do
      searchable true
    end

    field :name do
      searchable true
    end

    field :user do
      searchable true
    end

  end

  config.model 'MatchingServiceRequest' do

    field :page do
      searchable true
    end

    field :user do
      searchable true
    end

    field :created_at
    field :updated_at

    field :sent
    field :analysed

  end

  config.model 'User' do

    field :github_avatar do
      label do
        'Avatar'
      end
    end

    field :name do
      searchable true
    end

    field :email do
      searchable true
    end

    field :role, :enum do
      searchable true
      enum do
        User.role_options
      end
    end

    field :github_name do
      searchable true
    end

    field :created_at
    field :updated_at

    field :contribution_pages do
      sortable false
    end

    field :pages do
      sortable false
    end

    field :old_wiki_users do
      sortable false
    end

  end

  config.model 'Page' do

    field :full_title do
      label do
        'Wiki Title'
      end
      searchable true
    end

    field :raw_content do
      searchable true
    end

    field :namespace do
      hide
      searchable true
    end

    field :title do
      hide
      searchable true
    end

    field :users do
      sortable false
    end

    field :created_at
    field :updated_at

    edit do
      field :title do
        show
      end

      field :namespace do
        show
      end

      field :raw_content do
        show
      end

      field :contribution_folder do
        show
      end

      field :contribution_url do
        show
      end

      field :worker_findings do
        show
      end

    end

  end

end
