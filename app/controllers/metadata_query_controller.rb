require 'metadata/saml'

class MetadataQueryController < ApplicationController
  SAML_CONTENT_TYPE = 'application/samlmetadata+xml'.freeze
  SHA1_REGEX = /{sha1}(.*)?/

  include MetadataQueryCaching

  skip_before_action :ensure_authenticated
  before_action :ensure_get_request, :ensure_content_type,
                :ensure_accept_charset, :ensure_metadata_instance

  def all_entities
    public_action
    return head :not_found unless @metadata_instance.all_entities

    known_entities = KnownEntity.with_all_tags(@metadata_instance.primary_tag)
    return head :not_found unless known_entities.present?

    etag = generate_known_entities_etag(known_entities)
    if known_entities_unmodified?(known_entities, etag)
      return head :not_modified
    end

    create_known_entities_response(known_entities, etag)
  end

  def tagged_entities
    public_action

    tags = [@metadata_instance.primary_tag, params[:identifier]]
    known_entities = KnownEntity.with_all_tags(tags)
    return head :not_found unless known_entities.present?

    etag = generate_known_entities_etag(known_entities)
    if known_entities_unmodified?(known_entities, etag)
      return head :not_modified
    end

    create_known_entities_response(known_entities, etag)
  end

  def specific_entity
    public_action

    known_entity = EntityId.first(uri: params[:identifier])
                   .try(:parent).try(:known_entity)
    return head :not_found unless known_entity

    etag = generate_descriptor_etag(known_entity)
    return head :not_modified if known_entity_unmodified?(known_entity, etag)

    create_known_entity_response(known_entity, etag)
  end

  def specific_entity_sha1
    public_action

    sha1_identifier = params[:identifier].match(SHA1_REGEX)
    return head :not_found unless sha1_identifier

    known_entity = EntityId.first(sha1: sha1_identifier[1])
                   .try(:parent).try(:known_entity)
    return head :not_found unless known_entity

    etag = generate_descriptor_etag(known_entity)
    return head :not_modified if known_entity_unmodified?(known_entity, etag)

    create_known_entity_response(known_entity, etag)
  end

  private

  def ensure_get_request
    return if request.get?

    head :method_not_allowed
    false
  end

  def ensure_content_type
    return if request.accept == MetadataQueryController::SAML_CONTENT_TYPE

    head :not_acceptable
    false
  end

  def ensure_accept_charset
    return if !request.accept_charset || request.accept_charset == 'utf-8'

    head :not_acceptable
    false
  end

  def ensure_metadata_instance
    @metadata_instance =
      MetadataInstance[primary_tag: params[:primary_tag]]
    if @metadata_instance
      @saml_renderer = Metadata::SAML.new(metadata_instance: @metadata_instance)
      return
    end

    head :not_found
    false
  end

  def create_headers(obj, etag, expiry)
    response.headers['ETag'] = etag
    response.headers['Last-Modified'] = obj.updated_at.rfc2822
    response.headers['Content-Type'] =
      "#{MetadataQueryController::SAML_CONTENT_TYPE}; charset=utf-8"

    ttl = expiry - Time.now
    expires_in ttl
  end

  def create_known_entity_response(known_entity, etag)
    response = cache_descriptor_response(known_entity, etag)

    create_headers(known_entity, etag, response[:expires])
    render body: response[:metadata]
  end

  def create_known_entities_response(known_entities, etag)
    response = cache_known_entities_response(known_entities, etag)

    create_headers(known_entities.sort_by(&:updated_at).last,
                   etag, response[:expires])
    render body: response[:metadata]
  end
end
