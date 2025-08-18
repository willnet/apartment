# frozen_string_literal: true

module Apartment
  module Test
    # rubocop:disable Style/ModuleFunction
    extend self
    # rubocop:enable Style/ModuleFunction

    def reset
      Apartment.excluded_models = nil
      Apartment.use_schemas = nil
      Apartment.seed_after_create = nil
      Apartment.default_tenant = nil
    end

    def next_db
      @x ||= 0
      format('db%<db_idx>d', db_idx: @x += 1)
    end

    def drop_schema(schema)
      ActiveRecord::Base.connection.execute("DROP SCHEMA IF EXISTS #{schema} CASCADE")
    rescue StandardError => _e
      true
    end

    # Use this if you don't want to import schema.rb etc... but need the postgres schema to exist
    # basically for speed purposes
    def create_schema(schema)
      ActiveRecord::Base.connection.execute("CREATE SCHEMA #{schema}")
    end

    def load_schema(version = 3)
      file = File.expand_path("../../schemas/v#{version}.rb", __FILE__)

      silence_warnings { load(file) }
    end

    def migrate
      migrations_path = Rails.application.paths['db/migrate'].to_a
      if ActiveRecord.version.release < Gem::Version.new('7.1')
        ActiveRecord::MigrationContext.new(migrations_path, ActiveRecord::SchemaMigration).migrate
      else
        ActiveRecord::MigrationContext.new(migrations_path).migrate
      end
    end

    def rollback
      migrations_path = Rails.application.paths['db/migrate'].to_a
      if ActiveRecord.version.release < Gem::Version.new('7.1')
        ActiveRecord::MigrationContext.new(migrations_path, ActiveRecord::SchemaMigration).rollback
      else
        ActiveRecord::MigrationContext.new(migrations_path).rollback
      end
    end
  end
end
