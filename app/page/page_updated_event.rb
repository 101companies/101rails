class PageUpdatedEvent < Sequent::Core::Event
  attrs full_title: String, content: String
end
