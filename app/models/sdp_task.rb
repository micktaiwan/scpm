class SDPTask < ActiveRecord::Base

  attr_accessor :initial_should_be, :reevaluated_should_be, :difference

  def initialize
    super
    @initial_should_be      = 0.0
    @reevaluated_should_be  = 0.0
    @difference             = 0.0
  end

end

