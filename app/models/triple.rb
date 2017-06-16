class Triple < ApplicationRecord
  belongs_to :page

  before_save do |triple|
    triple.predicate = triple.predicate.camelize(:lower)
  end
end
