class Ability
  include CanCan::Ability

  def initialize(user)

    # get exsiting user or create new temporary user
    user ||= User.new

    # admin can manage everyting and has access to admin ui
    if user.role == 'admin'
      can :manage, :all
      can :access, :rails_admin
      can :dashboard
    end

    # editor can work with pages
    can :manage, Page if user.role == 'editor'

    # user can be manually has permissions to change concrete page
    can :manage, Page, :user_ids => user.id

  end

end
