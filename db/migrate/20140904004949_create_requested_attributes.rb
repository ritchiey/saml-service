Sequel.migration do
  change do

    # 'extends attribute'
    create_table :requested_attributes do
      primary_key :id
      String :reasoning, null: false
      TrueClass :required, null: false
      TrueClass :approved

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
