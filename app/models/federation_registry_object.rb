class FederationRegistryObject < Sequel::Model
  def self.local_instance(fr_id, class_name)
    fr_obj = find(fr_id: fr_id, internal_class_name: class_name)

    return class_name.constantize[fr_obj.internal_id] if fr_obj
    nil
  end
end
