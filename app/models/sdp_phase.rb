class SDPPhase < ActiveRecord::Base

  attr_accessor :gain_percent

  def initialize
    super
    @gain_percent = 0.0
  end

end
