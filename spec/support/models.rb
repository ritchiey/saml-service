# frozen_string_literal: true

shared_examples 'a basic model' do
  it do
    is_expected.to validate_presence :created_at
    is_expected.to validate_presence :updated_at
  end
end
