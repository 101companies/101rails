require 'rails_helper'

describe 'Page' do
  let(:aggregate_id) { Sequent.new_uuid }

  before :each do
    @command_handler = PageCommandHandler.new
  end

  it 'creates a page' do
    when_command CreatePage.new(
      aggregate_id: aggregate_id,
      full_title: 'Contribution::Java',
      content: 'text'
    )
    then_events PageCreatedEvent.new(
      aggregate_id: aggregate_id,
      sequence_number: 1,
      content: 'text',
      full_title: 'Contribution::Java'
    )

    # when_command UpdatePage.new(aggregate_id: aggregate_id, full_title: 'Contribution::Java', content: 'text')
    # then_events PageUpdateEvent.new(aggregate_id: aggregate_id, sequence_number: 1)
  end
end
