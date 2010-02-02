require 'machinist/mongomapper'

Sham.composant { /\w+/.gen }
Sham.name { /\w+/.gen }
Sham.message { /[:paragraph:]/.gen }

Error.blueprint do
  project { Project.make }
  message
  resolved { false }
  raised_at { Time.now }
  backtrace ['[PROJECT_ROOT]/vendor/gems/mongo-0.18/lib/../lib/mongo/types/objectid.rb:73:in `from_string',
  '[PROJECT_ROOT]/vendor/gems/mongo_mapper-0.6.4/lib/mongo_mapper/finder_options.rb:64:in `to_mongo_criteria']
end

Project.blueprint do
  name
end
