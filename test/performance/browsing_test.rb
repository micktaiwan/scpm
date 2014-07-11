require 'test_helper'
require 'performance_test_help'

# Profiling results for each test method are written to tmp/performance.
class BrowsingTest < ActionController::PerformanceTest

  include Authentication

  def setup
    session[:user_id] = Person.find_by_login('mfaivremacon')
    session[:project_filter_qr] = "('#{current_user.id}')"
    session[:project_sort]      = nil
    session[:context] = 'reporting'
  end

    def test_homepage
    get '/projects'
  end
end

