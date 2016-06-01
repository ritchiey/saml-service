# frozen_string_literal: true
module API
  class RawEntityDescriptorsController < APIController
    before_action do
      @entity_source = EntitySource[source_tag: params[:tag]]
      raise(ResourceNotFound) if @entity_source.nil?
    end

    def create
      check_access!(access_path)
      raise(BadRequest) unless valid_post_params?
      persist
      render status: :created, nothing: true
    end

    private

    def persist
      Sequel::Model.db.transaction(isolation: :repeatable) do
        ke = KnownEntity.create(entity_source: @entity_source,
                                enabled: post_params[:enabled])
        red = RawEntityDescriptor
              .create(known_entity: ke, xml: post_params[:xml],
                      enabled: post_params[:enabled], idp: true, sp: false)
        EntityId.create(uri: post_params[:entity_id],
                        raw_entity_descriptor: red)
        tag_known_entity(ke)
      end
    end

    def tag_known_entity(known_entity)
      post_params[:tags].each { |t| known_entity.tag_as(t) }
      known_entity.tag_as(params[:tag])
    end

    def post_params
      params.require(:raw_entity_descriptor)
            .permit(:xml, :entity_id, :enabled, tags: [])
    end

    def valid_post_params?
      post_params[:tags] && [true, false].include?(post_params[:enabled])
    end

    def access_path
      "entity_sources:#{@entity_source.source_tag}:raw_entity_descriptors:"\
      'create'
    end
  end
end
