Sequel.migration do
  change do

    create_table :ca_key_infos do
      primary_key :id
    end

  end
end
