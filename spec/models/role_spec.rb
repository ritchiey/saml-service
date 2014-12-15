require 'rails_helper'

RSpec.describe Role, type: :model do
  subject { create :role }
  it 'has a valid factory' do
    expect(subject).to be_valid
  end
  it 'is invalid without a name' do
    subject.name = nil
    expect(subject).not_to be_valid
  end
end
