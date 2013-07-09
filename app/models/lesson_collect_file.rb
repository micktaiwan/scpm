class LessonCollectFile < ActiveRecord::Base
 has_many    :lesson_collects, 				:dependent=>:nullify
 has_many    :lesson_collect_actions,   	:dependent=>:nullify
 has_many    :lesson_collect_assessments,   :dependent=>:nullify
end
