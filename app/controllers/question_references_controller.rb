class QuestionReferencesController < ApplicationController
  layout "tools"
  def index
    @axesList = PmTypeAxe.find(:all).map{|u| [u.title,u.id]}
    @lifecycleList = Lifecycle.find(:all).map{ |l| [l.name, l.id]}
    
    @firstAxeId = @axesList.first[1]
    @firstLifecycleId = @lifecycleList.first[1]
  end

  def generate_question_references_table
    axe_id = params[:axe_id]
    lifecycle_id = params[:lifecycle_id]
    @questionReferencesList = QuestionReference.find(:all,
      :joins => ["JOIN lifecycle_questions ON lifecycle_questions.id = question_references.question_id",
                 "JOIN pm_type_axes ON lifecycle_questions.pm_type_axe_id = pm_type_axes.id",
                 "JOIN pm_types ON pm_type_axes.pm_type_id = pm_types.id",
                 "JOIN lifecycles ON lifecycle_questions.lifecycle_id = lifecycles.id",
                 "JOIN milestone_names ON question_references.milestone_id = milestone_names.id"],
      :conditions => ["pm_type_axes.id = ? and lifecycles.id = ?",axe_id.to_s, lifecycle_id.to_s])
      render(:layout=>false)
  end
  
  
  def save_question_reference
    question_reference_id = params[:question_reference_id]
    question_reference_note = params[:question_reference_note]
    
    question_ref_to_update = QuestionReference.find(question_reference_id)
    question_ref_to_update.note = question_reference_note
    question_ref_to_update.save
    render :layout => false     
  end
  
end
