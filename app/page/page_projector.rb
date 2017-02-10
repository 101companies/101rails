class PageProjector < Sequent::Core::Projector

  on PageCreatedEvent do |event|
    parsed_title = PageModule.retrieve_namespace_and_title(event.full_title)

    create_record(
      PageRecord,
      aggregate_id: event.aggregate_id,
      title: parsed_title['title'],
      namespace: parsed_title['namespace'],
      raw_content: event.content
    )
  end

  on RepoLinkUpdatedEvent do |event|
    page = get_record!(
      PageRecord,
      aggregate_id: event.aggregate_id
    )

    page.repo_link_record ||= RepoLinkRecord.new
    page.repo_link_record.folder = event.folder
    page.repo_link_record.user = event.user
    page.repo_link_record.repo = event.repo
    page.save!
  end

end
