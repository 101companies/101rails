class UpdateRepoLink < Sequent::Core::Command
  validates :page_id, presence: true

  def initialize(args)
    args[:aggregate_id] = args[:aggregate_id].to_s

    super(args)
  end

  attrs folder: String, user: String, repo: String, page_id: String, user_id: String
end
