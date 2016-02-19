# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'rails/generators'
require 'rake'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

require File.expand_path('./helpers.rb', File.dirname(__FILE__))
require File.expand_path('./controller_helpers.rb', File.dirname(__FILE__))

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.include FactoryGirl::Syntax::Methods

  config.extend Helpers
  config.include ControllerHelpers, type: :controller

  config.before(:suite) do
    Dir.chdir(File.expand_path('..', File.dirname(__FILE__))) do
      Dir.glob("db/migrate/**.rb").each do |f|
        FileUtils.rm(f) if f =~ /.*(create_versions|add_object_changes|create_notifications).*/
      end
      helper_path = "app/helpers/what_happened_helper.rb"
      FileUtils.rm(helper_path) if File.exists?(helper_path)
      Rails::Generators::Base.new.generate("paper_trail:install", "--with-changes")
      Rails::Generators::Base.new.generate("what_happened:install")
      load(helper_path)
      Rails.application.load_tasks
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      Rake::Task["db:migrate"].invoke
    end
  end
end

RSpec::Matchers.define :notify do |expected|
  match do |actual|
    before = expected.what_happened.to_a
    actual.call
    if expected.what_happened.count <= before.size
      return false
    end

    if @about
      old_ids = before.collect(&:id)
      new_notifications = expected.what_happened.to_a.select do |n|
        !old_ids.include?(n.id)
      end

      unless new_notifications.collect(&:label).include?(@about.to_s)
        return false
      end
    end
    return true
  end

  chain :about do |about|
    @about = about
  end

  failure_message do |actual|
    s = "expected that #{expected.inspect} would be notified"
    if @about
      s << " about #{@about}"
    end
    s << ", but wasn't."
  end

  failure_message_when_negated do |actual|
    s = "expected that #{expected.inspect} would not be notified"
    if @about
      s << " about #{@about}"
    end
    s << ", but it was."
  end

  supports_block_expectations
end

require File.expand_path('../factories', __FILE__)
