class Impression < ActiveRecord::Base
  attr_accessible :impressionable_type, :impressionable_id, :controller_name,
                  :action_name, :user_id, :request_hash, :session_hash,
                  :ip_address, :referrer
end