# 
# Tie Viscacha to the ActiveSupport namespace
# 
require 'active_support/cache'
require 'viscacha/store'

class ActiveSupport::Cache::Viscacha < Viscacha::Store
end
