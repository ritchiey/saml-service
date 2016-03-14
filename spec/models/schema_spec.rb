require 'rails_helper'
require 'gumboot/shared_examples/database_schema'

RSpec.describe 'Database Schema' do
  let(:connection) { Sequel::Model.db.connect(Sequel::Model.db.uri) }

  include_context 'Database Schema'
end
