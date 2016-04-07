module WhatHappened
  class Railtie < Rails::Railtie
    config.what_happened = ActiveSupport::OrderedOptions.new
    config.what_happened.disabled = false
    config.what_happened.after_commit = true
    initializer "what_happened.create_config" do |app|
      WhatHappened.config = Config.new

      app.config.after_initialize do
        ActiveRecord::Base.send(:include, WhatHappened::ModelConcern)

        unless app.config.what_happened.fetch(:disabled, true)
          path = File.join(app.root, "config", "notification_routing.rb")
          if File.exist?(path)
            specification = <<-SPEC
              specify do
                #{File.read(path)}
              end
            SPEC
            WhatHappened.config.instance_eval(specification)

            WhatHappened.config.hook_into_active_record_cycle
          end
        end
      end
    end
  end
end
