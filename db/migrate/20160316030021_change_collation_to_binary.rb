Sequel.migration do
  up do
    run 'ALTER DATABASE COLLATE = utf8_bin'
  end

  down do
  end
end
