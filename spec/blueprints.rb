require 'machinist/mongomapper'

Sham.composant { /\w+/.gen }
Sham.name { /\w+/.gen }
Sham.message { /[:paragraph:]/.gen }

MLogger.blueprint do
  project { Project.make }
  composant
  message
  severity { rand(5) }
end

Project.blueprint do
  name
end
