require 'rails_helper'

describe Endpoint do

  it { is_expected.to validate_presence :location }
  it { is_expected.to validate_format %r{https?://[\S]+}, :location }
  it { is_expected.to validate_format %r{https?://[\S]+}, :response_location }

  it { is_expected.to validate_presence :created_at }
  it { is_expected.to validate_presence :updated_at }

  shared_examples 'a url' do
  end

  context 'location' do
    it 'rejects invalid URL' do
      subject.location = 'invalid'
      expect(subject.valid?).to be false
    end

    context 'valid URL formats' do
      it 'http' do
        subject.location = 'http://example.org'
        expect(subject.valid?).to be true
      end

      it 'https' do
        subject.location = 'https://example.org'
        expect(subject.valid?).to be true
      end

      it 'with port number' do
        subject.location = 'https://example.org:8080'
        expect(subject.valid?).to be true
      end
    end
  end

  context 'response_location' do
    subject { FactoryGirl.create(:endpoint) }

    it 'rejects invalid URL' do
      subject.response_location = 'invalid'
      expect(subject.valid?).to be false
    end

    context 'valid URL formats' do
      it 'http' do
        subject.response_location = 'http://example.org'
        expect(subject.valid?).to be true
      end

      it 'https' do
        subject.response_location = 'https://example.org'
        expect(subject.valid?).to be true
      end

      it 'with port number' do
        subject.response_location = 'https://example.org:8080'
        expect(subject.valid?).to be true
      end
    end
  end
end
