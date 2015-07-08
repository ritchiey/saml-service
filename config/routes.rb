Rails.application.routes.draw do
  uri_regexp = URI.regexp(%w(http https urn:mace))
  sha1_regex = /{sha1}(.*)?/

  match '/:primary_tag/entities',
        to: 'metadata_query#all_entities', via: :all

  match '/:primary_tag/entities/:identifier',
        to: 'metadata_query#specific_entity',
        constraints: { identifier: uri_regexp }, via: :all

  match '/:primary_tag/entities/:identifier',
        to: 'metadata_query#specific_entity_sha1',
        constraints: { identifier: sha1_regex }, via: :all

  match '/:primary_tag/entities/:identifier',
        to: 'metadata_query#tagged_entities', via: :all
end
