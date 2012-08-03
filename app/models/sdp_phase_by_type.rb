class SDPPhaseByType < ActiveRecord::Base
  set_table_name 'sdp_phases_by_type'
  attr_accessor :gain_percent

  def initialize
    super
    @gain_percent = 0.0
  end
  
end
