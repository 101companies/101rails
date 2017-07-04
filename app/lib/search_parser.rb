class SearchParser < Parslet::Parser
  rule(:space)      { match('\s').repeat(1) }
  rule(:space?)     { space.maybe }

  rule(:text)      { match('[a-zA-Z0-9_\:]').repeat(1) }
  rule(:query)     { (text.as(:identifier) >> match('=') >> text.as(:value)).as(:query) }

  rule(:search)    { (query | text.as(:text) | space).repeat(1).as(:search) }

  root :search
end
