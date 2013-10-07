class Ability
  include CanCan::Ability

  def initialize(user)

    # get exsiting user or create new temporary user
    user ||= User.new

    # permissions for work in admin interface
    if user && user.role == 'admin'
      can :manage, :all
      can :access, :rails_admin
      can :dashboard
    end

    # page can be updated, if user is admin or editor, or user owns the page
    can :update, Page do |page|
      user.role == 'editor' or page.users.include? user
    end

    can :administrate_contribution, Page do
      user.role == 'editor'
    end

    can :update_contribution, Page do |page|
      user.role == 'editor' or page.users.include? user
    end

    # page can be renamed, if user is admin or editor
    can :rename, Page do
      user.role == 'editor'
    end

    # page can be renamed, if user is admin or editor
    can :delete, Page do
      user.role == 'editor'
    end

    # page can be created, if user is admin or editor
    can :create, Page do
      user.role == 'editor'
    end

  end

end
