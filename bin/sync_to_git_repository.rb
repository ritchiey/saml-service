#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'
require 'rugged'
require 'metadata/saml'

class SyncToGitRepository
  include Metadata::SAMLNamespaces

  def initialize(args)
    if args.length != 2
      $stderr.puts("usage: #{$PROGRAM_NAME} md_instance_identifier " \
                   '/path/to/git/repository')
      exit 1
    end

    instance_identifier, repository_path = args
    @md_instance = MetadataInstance[identifier: instance_identifier]
    @repository = Rugged::Repository.new(repository_path)
  end

  def perform
    known_entities = KnownEntity.with_all_tags([@md_instance.primary_tag])
    touched = known_entities.map { |ke| sync(ke) }
    sweep(touched)
  end

  private

  def sync(ke)
    encoded_entity_id = Base64.urlsafe_encode64(ke.entity_id, padding: false)
    filename = "entities/#{@md_instance.identifier}-#{encoded_entity_id}.xml"

    write_metadata(ke, filename, generate_metadata(ke))

    filename
  end

  def sweep(touched)
    prefix = "entities/#{@md_instance.identifier}-"

    all = @repository.index.map { |e| e[:path] }
                     .select { |p| p.start_with?(prefix) }

    (all - touched).each { |path| remove_stale(path) }
  end

  def write_metadata(ke, filename, xml)
    full_path = File.join(@repository.workdir, filename)
    File.open(full_path, 'w') { |f| f.write(xml) }

    return if @repository.status(filename).empty?

    commit_changes("[sync] #{ke.entity_id}") do |index|
      object_id = @repository.write(xml, :blob)
      index.add(path: filename, oid: object_id, mode: 0o100644)
    end
  end

  def generate_metadata(ke)
    renderer = Metadata::SAML.new(metadata_instance: @md_instance)

    if ke.entity_descriptor.try(:functioning?)
      renderer.entity_descriptor(ke.entity_descriptor, NAMESPACES)
    elsif ke.raw_entity_descriptor.try(:functioning?)
      renderer.raw_entity_descriptor(ke.raw_entity_descriptor, NAMESPACES, true)
    end

    doc = renderer.builder.doc
    doc.to_xml(indent: 2)
  end

  def remove_stale(path)
    full_path = File.join(@repository.workdir, path)
    FileUtils.rm_f(full_path)

    commit_changes('[sync] remove stale entity') do |index|
      index.remove(path)
    end
  end

  def commit_changes(message)
    index = @repository.index
    index.read_tree(@repository.head.target.tree)

    yield index

    index.write

    tree = index.write_tree(@repository)
    commit(tree, message)
  end

  def commit(tree, message)
    author = {
      name: 'SAML Service',
      time: Time.now.getlocal,
      email: 'noreply@aaf.edu.au'
    }

    Rugged::Commit.create(@repository,
                          tree: tree, message: message,
                          author: author, committer: author,
                          parents: [@repository.head.target],
                          update_ref: 'HEAD')
  end
end

SyncToGitRepository.new(ARGV).perform if $PROGRAM_NAME == __FILE__
