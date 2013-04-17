class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new

    # permissions for work in admin inteface
    if user && user.role == 'admin'
      can :manage, :all
      can :access, :rails_admin
      can :dashboard
    end

    # page can be updated, if user is admin or editor, or user owns the page
    can :update, Page do |page|
      user.role == 'admin' or user.role == 'editor' or page.try(:user) == user
    end

  end

end
