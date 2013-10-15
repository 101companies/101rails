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
    (can :manage, Page) if user.role == 'editor'

    # user can change the page, if it's his page
    # he listed in list of users or is contributor of the page
    # or he edited this page in old wiki
    can :manage, Page do |page|
        page.contributor == user or page.users.include? user
    end

  end

end
