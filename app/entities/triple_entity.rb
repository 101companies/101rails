class TripleEntity < Dry::Struct
  attribute :predicate, Types::Strict::String
  attribute :object, Types::Strict::String
end
