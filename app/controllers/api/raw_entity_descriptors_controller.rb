# frozen_string_literal: true
module API
  class RawEntityDescriptorsController < APIController
    before_action do
      @entity_source = EntitySource[source_tag: params[:tag]]
      raise(ResourceNotFound) if @entity_source.nil?
    end

    def update
      check_access!(access_path)
      raise(BadRequest) unless valid_patch_params?
      if existing_entity_id
        update_raw_entity_descriptor
        render status: :no_content, nothing: true
      else
        create_raw_entity_descriptor
        render status: :created, nothing: true
      end
    end

    private

    def update_raw_entity_descriptor
      red = existing_entity_id.raw_entity_descriptor
      red.xml = patch_params[:xml]
      red.enabled = patch_params[:enabled]
      ke = red.known_entity
      ke.enabled = patch_params[:enabled]
      Sequel::Model.db.transaction(isolation: :repeatable) do
        red.save
        ke.save
        tag_known_entity(ke)
      end
    end

    def create_raw_entity_descriptor
      Sequel::Model.db.transaction(isolation: :repeatable) do
        ke = KnownEntity.create(entity_source: @entity_source,
                                enabled: patch_params[:enabled])
        red = RawEntityDescriptor
              .create(known_entity: ke, xml: patch_params[:xml],
                      enabled: patch_params[:enabled], idp: true, sp: false)
        EntityId.create(uri: entity_id_uri,
                        raw_entity_descriptor: red)
        tag_known_entity(ke)
      end
    end

    def existing_entity_id
      EntityId.first(entity_source_id: @entity_source.id,
                     uri: entity_id_uri)
    end

    def tag_known_entity(known_entity)
      patch_params[:tags].each { |t| known_entity.tag_as(t) }
      known_entity.tag_as(params[:tag])
    end

    def patch_params
      params.require(:raw_entity_descriptor)
            .permit(:xml, :entity_id, :enabled, tags: [])
    end

    def entity_id_uri
      Base64.urlsafe_decode64(params[:base64_urlsafe_entity_id])
    end

    def valid_patch_params?
      patch_params[:tags] && [true, false].include?(patch_params[:enabled])
    end

    def access_path
      "entity_sources:#{@entity_source.source_tag}:raw_entity_descriptors:"\
      'create'
    end
  end
end
