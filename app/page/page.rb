class Page < Sequent::Core::AggregateRoot

  def initialize(command)
    super(command.aggregate_id)

    apply PageCreatedEvent, full_title: command.full_title, content: command.content
  end

  def update_page(full_title, content)
    apply PageUpdateEvent, full_title: full_title, content: content
  end

  def update_repo_link(folder, user, repo, page_id, user_id: nil)
    apply RepoLinkUpdatedEvent, folder: folder, user: user, page_id: page_id, user_id: user_id
  end

end
