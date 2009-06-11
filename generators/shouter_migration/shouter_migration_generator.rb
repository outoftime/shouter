class ShouterMigrationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'migrations/create_shouter_tables.rb', 'db/migrate'
    end
  end

  def file_name
    "create_shouter_tables"
  end
end
