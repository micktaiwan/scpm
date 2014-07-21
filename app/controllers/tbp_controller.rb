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
        #puts @rv.inspect
        @rv['data']['collaborateurs'].each { |l|
          TbpCollab.create(:tbp_id=>l['id'],:lastname=>l['nom'], :firstname=>l['prenom'], :activity=>l['activite'], :te=>l['te'])
          }
        }
      # update TbpProjects
      TbpProject.delete_all
      open("http://toulouse.sqli.com/tbp/restService/public/projets.json", "Authorization"=>"Basic #{APP_CONFIG['tbp_auth']}") {|f|
        @rv = JSON.parse(f.read)
        #puts @rv.inspect
        @rv['data']['projets'].each { |l|
          TbpProject.create(:tbp_id=>l['id'],:name=>l['libelle'], :agresso=>l['agresso'], :activity=>l['activite'], :ttype=>l['type'])
          }
        }
    rescue Exception => e
      render(:text=>e.message)
      return
    end
    render(:text=>'ok')
  end

  def collab
    id = params['id']
    @collab = TbpCollab.find_by_tbp_id(id)
    @dates  = TbpCollabWork.find_all_by_tbp_collab_id(id)
  end

  def update_collab
    @rv = ""
    begin
      id = params['id'].to_i
      TbpCollabWork.delete_all("tbp_collab_id='#{id}'")
      open("http://toulouse.sqli.com/tbp/restService/public/collaborateurs/#{id}/charge.json?date_debut=2014-07-14&date_fin=2014-07-31", "Authorization"=>"Basic #{APP_CONFIG['tbp_auth']}") {|f|
        @rv = JSON.parse(f.read)
        puts @rv.inspect
        @rv['data']['charge'].each { |l|
          date = l['date']
          l['projets'].each { |p|
            TbpCollabWork.create(:tbp_collab_id=>id,:date=>date, :tbp_project_id=>p['id'], :workload=>p['charge'])

           }
          }
        }
    rescue Exception => e
      render(:text=>e.message)
      return
    end
    render(:text=>'ok')
  end


end
