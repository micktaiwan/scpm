class SuiteTagsController < ApplicationController
layout 'tools'


def index
	suiteTags   = SuiteTag.find(:all)	
    @suiteTags  = suiteTags.sort_by{ |st|
      if st[:name].scan(/\d+[,.]\d+|\d+/).count > 0
        st[:name].scan(/\d+[,.]\d+|\d+/)[0].to_f
      else
        st[:name]
      end
    }
end

def new
end

def create
	suite_tag = SuiteTag.new(params[:suite_tag])
    if not suite_tag.save
      render :action => 'new'
      return
    end
    redirect_to :action=>:index
end

def edit
    id        = params[:id]
    @suite_tag = SuiteTag.find(id)
end

def update
	suite_tag = SuiteTag.find(params[:id])
    suite_tag.update_attributes(params[:suite_tag])
    redirect_to :action=>:index
end


def delete
	suite_tag = SuiteTag.find(params[:id])
	suite_tag.delete
    redirect_to :action=>:index
end

end
