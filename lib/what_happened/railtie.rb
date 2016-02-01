module WhatHappened
  class Railtie < Rails::Railtie
    config.what_happened = ActiveSupport::OrderedOptions.new
    config.what_happened.disabled = false
    initializer "what_happened.create_config" do |app|
      WhatHappened.config = Config.new

      app.config.after_initialize do
        ActiveRecord::Base.send(:include, WhatHappened::Model)
        unless app.config.what_happened.fetch(:disabled, true)
          PaperTrail::Version.after_create do |version|
            BroadcastJob.perform_later(version)
          end
          PaperTrail::Version.after_update do |version|
            BroadcastJob.perform_later(version)
          end
          PaperTrail::Version.after_destroy do |version|
            BroadcastJob.perform_later(version)
          end


          path = File.join(app.root, "config", "notification_routing.rb")
          if File.exist?(path)
            specification = <<-SPEC
              specify do
                #{File.read(path)}
              end
            SPEC
            WhatHappened.config.instance_eval(specification)
          end
        end
      end
    end
  end
end
