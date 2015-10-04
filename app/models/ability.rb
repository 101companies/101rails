class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new

    # admin can manage everyting and has access to admin ui
    if user.role == 'admin'
      can :manage, :all
      can :access, :rails_admin
      can :dashboard
    end

    # editor can work with pages
    if user.role == 'editor'
      can :manage, Page
    end

    # user can create own contribution page
    can :manage, Page, :title => user.github_name, :namespace => 'Contributor'

    cannot :history, :all
  end

end
