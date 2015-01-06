Sequel.migration do
  change do
    create_table :api_subjects_roles do
      foreign_key :role_id, :roles, null: false,
                  foreign_key_constraint_name: 'api_subject_role_fkey'
      foreign_key :api_subject_id, :api_subjects, null: false,
                  foreign_key_constraint_name: 'role_api_subject_fkey'
    end
  end
end
