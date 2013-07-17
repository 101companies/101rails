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

  # history of object changes with mongodb
  #config.audit_with :mongoid_audit, 'HistoryTracker'

  # Set the admin name here (optional second array element will appear in red). For example:
  config.main_app_name = ['101Wiki', 'Admin']

  # RailsAdmin may need a way to know who the current user is]
  config.current_user_method { current_user } # auto-generated

  # use roles system for blocking admin interface
  config.authorize_with :cancan

  # Display empty fields in show views:
  config.compact_show_view = false
  # Number of default rows per-page:
  config.default_items_per_page = 30

  # Exclude specific models (keep the others):
  config.excluded_models = ['History', 'HistoryTracker']

  config.model 'Contribution' do

    field :title do
      searchable true
    end

    field :url do
      searchable true
      label do
        'Repo url'
      end
      pretty_value do
        "<a target='_blank' href='#{value}'/>#{value}</a>".html_safe
      end
    end

    field :approved
    field :analyzed

    field :user do
      searchable true
    end

    field :page

    field :languages do
      searchable true
      pretty_value do
        Contribution.array_to_string value
      end
    end

    field :concepts do
      searchable true
      pretty_value do
        Contribution.array_to_string value
      end
    end

    field :technologies do
      searchable true
      pretty_value do
        Contribution.array_to_string value
      end
    end

    field :features do
      searchable true
      pretty_value do
        Contribution.array_to_string value
      end
    end

    field :description do
      searchable true
      hide
    end

    field :created_at
    field :updated_at

  end

  config.model 'OldWikiUser' do

    field :email do
      searchable true
      pretty_value do
        "<a href='mailto:#{value}'/>#{value}</a>".html_safe
      end
    end

    field :name do
      searchable true
    end

    field :user do
      searchable true
    end

  end

  config.model 'User' do

    field :github_avatar do
      label do
        'Avatar'
      end
      pretty_value do
        "<img width=24 height=24 src='#{value}'/>".html_safe
      end
    end

    field :name do
      searchable true
    end

    field :email do
      searchable true
      pretty_value do
        "<a href='mailto:#{value}'/>#{value}</a>".html_safe
      end
    end

    field :role, :enum do
      searchable true
      enum do
        User.role_options
      end
    end

    field :github_name do
      searchable true
      pretty_value do
        "<a target='_blank' href='https://github.com/#{value}'/>#{value}</a>".html_safe
      end
    end

    field :created_at
    field :updated_at

    field :pages do
      sortable false
    end

    field :contributions do
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

    field :contribution

    field :created_at
    field :updated_at

    edit do
      field :namespace do
        show
      end

      field :title do
        show
      end
    end

  end

end
