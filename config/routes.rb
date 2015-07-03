Rails.application.routes.draw do
  uri_regexp = URI.regexp(%w(http https urn:mace))

  match '/:primary_tag/entities',
        to: 'metadata_query#all_entities', via: :all

  match '/:primary_tag/entities/:identifier',
        to: 'metadata_query#specific_entity',
        constraints: { identifier: uri_regexp }, via: :all

  match '/:primary_tag/entities/:identifier',
        to: 'metadata_query#tagged_entities', via: :all
end
