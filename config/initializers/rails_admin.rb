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

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
