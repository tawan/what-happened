module Helpers
  def with_notification_routing(&specification)
    before do
      # create and mount thread local config
      WhatHappened::ConfigRegistry.config = WhatHappened::Config.new
      WhatHappened::ConfigRegistry.config.specify &specification
      WhatHappened::ConfigRegistry.config.append_paper_trail
    end

    after do
      # fall back to global config
      WhatHappened::ConfigRegistry.config = nil
    end
  end
end
