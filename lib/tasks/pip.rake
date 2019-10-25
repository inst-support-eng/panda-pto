desc 'remove new hires from 90 day pip'
task new_hire_check_pip: :environment do
  NewHireCheck.update_on_pip
end
