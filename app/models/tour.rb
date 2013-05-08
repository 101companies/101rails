class Tour

  field :title, String

  key :user_id, ObjectID

  def create(title)
  	@title = title
  end
end
