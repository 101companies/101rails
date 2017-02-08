class PageCreatedEvent < Sequent::Core::Event
  attrs full_title: String, content: String
end
