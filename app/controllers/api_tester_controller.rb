require 'open-uri'
require 'json'
OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)

class ApiTesterController < ApplicationController

  def index
  end

  def test_tbp
    url = params[:url]
    puts url.inspect
    open("#{APP_CONFIG['tbp_auths'][0]['url']}/#{url}", {"Authorization"=>"Basic #{APP_CONFIG['tbp_auths'][0]['auth']}"}) {|f|
      @rv = JSON.parse(f.read)
      #puts @rv.inspect
      }
    render(:text=>@rv.inspect)
  end

end
