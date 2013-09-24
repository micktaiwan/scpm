class TagsController < ApplicationController
  
  layout 'pdc'

  def index
  	@wl_lines = WlLine.find(:all, :conditions=>"project_id=2", :order=>"project_id, person_id")
    #@projects = Project.all # for filter
  end

  def add_tag
    tag_name  = params[:tag_name].titleize
    line_id   = params[:line_id]
    tag       = Tag.find_by_name(tag_name)
    tag       = Tag.create(:name=>tag_name) if tag.nil?
    LineTag.create(:line_id=>line_id, :tag_id=>tag.id) if LineTag.find_by_line_id_and_tag_id(line_id,tag.id).nil?
    render(:nothing=>true)
  end

  def remove_tag
    tags         = params[:tags].split(',')
    line_id      = params[:line_id]
    new_tags_ids     = []
    tags.each do |t|
      new_tags_ids << Tag.find_by_name(t).id
    end
    if new_tags_ids.size == 0
      line_tag_remove = LineTag.find_by_line_id(line_id)
    else
      line_tag_remove = LineTag.find(:first, :conditions=>["tag_id not in (#{new_tags_ids.join(',')}) and line_id=#{line_id}"])
    end
    tag_id_remove   = line_tag_remove.tag_id
    line_tag_remove.destroy
    Tag.find(tag_id_remove).destroy if LineTag.find_by_tag_id(tag_id_remove).nil?
    render(:nothing=>true)
  end
end
