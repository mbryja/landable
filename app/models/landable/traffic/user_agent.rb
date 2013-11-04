module Landable
  module Traffic
    class UserAgent < ActiveRecord::Base
      self.table_name = 'traffic.user_agents'
      self.record_timestamps = false

      lookup_by  :user_agent, cache: 50, find_or_create: true

      lookup_for :user_agent_type, class_name: UserAgentType
      lookup_for :device,          class_name: Device
      lookup_for :platform,        class_name: Platform
      lookup_for :browser,         class_name: Browser

      has_many :visitors

      before_save do
        self.user_agent_type ||= case user_agent
                                 when /pingdom|newrelicpinger/i
                                   'ping'
                                 when /scanalert|tinfoilsecurity/i
                                   'scan'
                                 when /bot|crawl|spider/i
                                   'crawl'
                                 end
      end
    end
  end
end
