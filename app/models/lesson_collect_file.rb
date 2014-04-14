class LessonCollectFile < ActiveRecord::Base
 has_many    :lesson_collects, 				:dependent=>:destroy
 has_many    :lesson_collect_actions,   	:dependent=>:destroy
 has_many    :lesson_collect_assessments,   :dependent=>:destroy
end
