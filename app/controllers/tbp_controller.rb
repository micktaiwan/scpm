require 'open-uri'
require 'json'
OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)

class TbpController < ApplicationController
  layout "tools"
  
  def index
    @collabs = TbpCollab.all
  end

  def update
    begin
      # update TbpCollabs
      TbpCollab.delete_all
      for i in (0..APP_CONFIG['tbp_urls'].size-1) do
        open("#{APP_CONFIG['tbp_urls'][i]}/collaborateurs.json", "Authorization"=>"Basic #{APP_CONFIG['tbp_auths'][i]}") {|f|
          rv = JSON.parse(f.read)
          #puts @rv.inspect
          rv['data']['collaborateurs'].each { |l|
            TbpCollab.create(:account_index=>i , :tbp_id=>l['id'],:lastname=>l['nom'], :firstname=>l['prenom'], :activity=>l['activite'], :te=>l['te'])
            }
          }
      end
      # update TbpProjects
      TbpProject.delete_all
      for i in (0..APP_CONFIG['tbp_urls'].size-1) do
        open("#{APP_CONFIG['tbp_urls'][i]}/projets.json", "Authorization"=>"Basic #{APP_CONFIG['tbp_auths'][i]}") {|f|
          rv = JSON.parse(f.read)
          #puts @rv.inspect
          rv['data']['projets'].each { |l|
            TbpProject.create(:tbp_id=>l['id'],:name=>l['libelle'], :agresso=>l['agresso'], :activity=>l['activite'], :ttype=>l['type'])
            }
          }
      end
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
    begin
      id = params['id'].to_i
      TbpCollabWork.delete_all("tbp_collab_id='#{id}'")
      index = TbpCollab.find_by_tbp_id(id).account_index
      open("#{APP_CONFIG['tbp_urls'][index]}/collaborateurs/#{id}/charge.json?date_debut=2014-07-14&date_fin=2014-07-31", "Authorization"=>"Basic #{APP_CONFIG['tbp_auths'][index]}") {|f|
        rv = JSON.parse(f.read)
        # puts @rv.inspect
        rv['data']['charge'].each { |l|
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
    TbpCollab.find_by_tbp_id(id).update_attribute(:last_update, DateTime.now())
    render(:text=>'ok')
  end


end
