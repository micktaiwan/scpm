require 'open-uri'
require 'json'
OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)

class TbpController < ApplicationController
  layout "tools"
  
  def index
    @collabs = TbpCollab.all
  end

  def update
    @rv = ""
    begin
      # update TbpCollabs
      TbpCollab.delete_all
      open("http://toulouse.sqli.com/tbp/restService/public/collaborateurs.json", "Authorization"=>"Basic #{APP_CONFIG['tbp_auth']}") {|f|
        @rv = JSON.parse(f.read)
        puts @rv.inspect
        @rv['data']['collaborateurs'].each { |l|
          TbpCollab.create(:tbp_id=>l['id'],:lastname=>l['nom'], :firstname=>l['prenom'], :activity=>l['activite'], :te=>l['te'])
          }
        }

      # open("http://toulouse.sqli.com/tbp/restService/public/collaborateurs/450/charge?date_debut=2014-07-14&date_fin=2014-07-31", "Authorization"=>"Basic #{APP_CONFIG['tbp_auth']}") {|f|
      #   @rv = f.read
      #   }
    rescue Exception => e
      render(:text=>e.message)
      return
    end
    render(:text=>'ok')
  end

end
