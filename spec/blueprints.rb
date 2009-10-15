require 'machinist/mongomapper'

Sham.application { /\w+/.gen }
Sham.composant { /\w+/.gen }
Sham.message { /[:paragraph:]/.gen }

MLogger.blueprint do
  application
  composant
  message
  severity { rand(5) }
end
