Sequel.migration do
  change do
    create_table :roles_subjects do
      foreign_key :role_id, :roles, null: false,
                  foreign_key_constraint_name: 'subject_role_fkey'
      foreign_key :subject_id, :subjects, null: false,
                  foreign_key_constraint_name: 'role_subject_fkey'
    end
  end
end
