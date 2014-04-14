class MonthlyTaskType < ActiveRecord::Base
  has_many   :monthly_tasks


 # Return the formated values with the current template
 def get_template_filled(name, load, login, date)
 	# Format name with the current date
	date_str = Date.today().year.to_s+"-"+template_filled_number(Date.today().month,2).to_s
	name_formated = name.to_s+" "+date_str.to_s
   	template_formated = self.template

	template_formated = template_formated.gsub("[NAME]", name_formated)
	template_formated = template_formated.gsub("[LOAD]", load.to_s)
	template_formated = template_formated.gsub("[DATE]", date.to_s)

	if (login != nil)
		template_formated = template_formated.gsub("[LOGIN]", login.to_s)
		template_formated = template_formated.gsub("[PROFIL]", "-1")
	else
		template_formated = template_formated.gsub("[LOGIN]", "")
		template_formated = template_formated.gsub("[PROFIL]", "1")
	end

	return template_formated
  end

  # Date operation
  def template_filled_number(n, nb)
    "0"*(nb-n.to_s.size) + n.to_s
  end

end
