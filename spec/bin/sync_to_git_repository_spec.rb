# frozen_string_literal: true

require 'rails_helper'
require_relative '../../bin/sync_to_git_repository'

RSpec.describe SyncToGitRepository do
  describe '#perform' do
    before do
      entity.tag_as(md_instance.primary_tag)

      allow(Rugged::Repository).to receive(:new).with(path).and_return(repo)
      allow(File).to receive(:open).with(file_path, 'w').and_yield(file)

      allow(repo).to receive(:status).with("entities/#{filename}")
        .and_return(file_status)

      allow(repo).to receive(:write).with(anything, :blob) do |content, blob|
        object_id = SecureRandom.urlsafe_base64
        written_blobs[object_id] = content
        object_id
      end

      allow(index).to receive(:write_tree).with(repo).and_return(new_tree)

      allow(Rugged::Commit).to receive(:create) { |*a| commit_spy.create(*a) }
    end

    let(:written_blobs) { {} }

    let(:encoded_entity_id) do
      Base64.urlsafe_encode64(entity.entity_id, padding: false)
    end

    let(:path) { Faker::Lorem.words.unshift('').join('/') }
    let(:filename) { "#{md_instance.identifier}-#{encoded_entity_id}.xml" }
    let(:file_path) { File.join(path, 'entities', filename) }
    let(:file) { spy(IO) }
    let(:file_status) { [] }
    let(:empty) { false }
    let(:md_instance) { create(:metadata_instance) }

    let(:commit_spy) { class_spy(Rugged::Commit) }
    let(:index) { spy(Rugged::Index) }
    let(:head_commit) { double(Rugged::Commit, tree: head_tree) }
    let(:head_tree) { double(Rugged::Tree) }
    let(:head) { double(Rugged::Reference, target: head_commit) }
    let(:new_tree) { double(Rugged::Tree) }

    let(:repo) do
      double(Rugged::Repository,
             empty?: empty, index: index, workdir: path, head: head)
    end

    subject { described_class.new([md_instance.identifier, path]) }

    def run
      subject.perform
    end

    def author
      {
        name: 'SAML Service',
        time: Time.now.getlocal,
        email: 'noreply@aaf.edu.au'
      }
    end

    shared_examples 'an updated entity' do
      it 'writes the file' do
        run
        expect(file).to have_received(:write).with(an_instance_of(String))
      end

      it 'commits the file' do
        Timecop.freeze do
          run

          expect(commit_spy).to have_received(:create)
            .with(repo,
                  author: author, committer: author, tree: new_tree,
                  message: "[sync] #{entity.entity_id}", parents: [head_commit],
                  update_ref: 'HEAD')
        end
      end
    end

    shared_examples 'an up-to-date entity' do
      it 'makes no commits' do
        run
        expect(commit_spy).not_to have_received(:create)
      end
    end

    shared_examples 'a removed entity' do
      it 'commits to remove the file' do
        Timecop.freeze do
          run

          expect(index).to have_received(:remove).with(stale)

          expect(commit_spy).to have_received(:create)
            .with(repo,
                  author: author, committer: author, tree: new_tree,
                  message: '[sync] remove stale entity', parents: [head_commit],
                  update_ref: 'HEAD')
        end
      end
    end

    context 'for a raw entity descriptor' do
      let(:raw_entity_descriptor) { create(:raw_entity_descriptor) }
      let!(:entity) { raw_entity_descriptor.known_entity }

      context 'for a new entity' do
        let(:file_status) { [:worktree_new] }
        it_behaves_like 'an updated entity'
      end

      context 'for a changed entity' do
        let(:file_status) { [:worktree_modified] }
        it_behaves_like 'an updated entity'
      end

      context 'for an unchanged entity' do
        let(:file_status) { [] }
        it_behaves_like 'an up-to-date entity'
      end

      context 'for a removed entity' do
        let(:stale) { "entities/#{md_instance.identifier}-stale-entity.xml" }

        before do
          allow(index).to receive(:map).and_return([stale])
        end

        it_behaves_like 'a removed entity'
      end
    end

    context 'for an entity descriptor' do
      let(:entity_descriptor) { create(:entity_descriptor, :with_idp) }
      let!(:entity) { entity_descriptor.known_entity }

      context 'for a new entity' do
        let(:file_status) { [:worktree_new] }
        it_behaves_like 'an updated entity'
      end

      context 'for a changed entity' do
        let(:file_status) { [:worktree_modified] }
        it_behaves_like 'an updated entity'
      end

      context 'for an unchanged entity' do
        let(:file_status) { [] }
        it_behaves_like 'an up-to-date entity'
      end
    end
  end
end
