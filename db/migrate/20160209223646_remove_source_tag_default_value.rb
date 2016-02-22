Sequel.migration do
  up do
    run('ALTER TABLE entity_sources ALTER source_tag DROP DEFAULT;')
  end

  down do
    alter_table :entity_sources do
      set_column_default :source_tag, 'aaf'
    end
  end
end
