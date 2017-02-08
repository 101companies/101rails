class PageCommandHandler < Sequent::Core::BaseCommandHandler

  on UpdatePage do |command|
    do_with_aggregate(command, Page) do |page|
      page.update_page(command.full_title, command.content)
    end
  end

  on CreatePage do |command|
    repository.add_aggregate Page.new(command)
  end

  on UpdateRepoLink do |command|
    do_with_aggregate(command, Page) do |page|
      page.update_repo_link(command.folder, command.user, command.repo, command.page_id, user_id: command.user_id)
    end
  end

end
