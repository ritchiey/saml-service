module StoreFederationRegistryData
  def create_or_update_by_fr_id(dataset, fr_id, **attrs)
    update_by_fr_id(dataset, fr_id, attrs) ||
      create_by_fr_id(dataset, fr_id, attrs) { |o| yield o if block_given? }
  end

  private

  def create_by_fr_id(dataset, fr_id, attrs)
    obj = dataset.model.new(attrs)
    yield obj if block_given?
    obj.save
    record_fr_id(obj, fr_id)
    obj
  end

  def update_by_fr_id(dataset, fr_id, attrs)
    obj = find_by_fr_id(dataset, fr_id)
    obj.try(:update, attrs)
    obj
  end

  def record_fr_id(object, fr_id)
    FederationRegistryObject.create(object_type: object.class.name,
                                    object_id: object.id,
                                    fr_id: fr_id)
  end

  def find_by_fr_id(dataset, fr_id)
    qual = ->(col) { Sequel.qualify(:federation_registry_objects, col) }

    ds = dataset.qualify.join(:federation_registry_objects, object_id: :id)
         .where(qual[:object_type] => dataset.model.name, qual[:fr_id] => fr_id)
    ds.first
  end
end
