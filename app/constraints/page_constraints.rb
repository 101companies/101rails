class PageConstraint
  def self.matches?(request)
    reserved_words = ['login', 'signup', 'signout', 'welcome', 'home']
    !reserved_words.include?(request.path_parameters[:username])
  end
end