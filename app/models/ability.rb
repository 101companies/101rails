class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    # admin can manage everyting and has access to admin ui
    if user.role == 'admin'
      can :manage, :all
      can :access, :rails_admin
      can :access, :dashboard
    end

    # editor can work with pages
    can :manage, Page if user.role == 'editor'

    if user.role == 'contributor'
      can :show, Page
      can :update, Page, user_ids: user.id
      can :rename, Page, user_ids: user.id
    end

    # user can create own contribution page
    can :manage, Page, title: user.github_name, namespace: 'Contributor'

    cannot :history, :all
  end
end
