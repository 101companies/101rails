class RepoLinkUpdatedEvent < Sequent::Core::Event
  attrs folder: String, user: String, repo: String, page_id: String, user_id: String
end
