namespace :import do

  desc "Import documents"
  task :documents do
    on roles(:web), in: :groups, limit: 3 do
      within current_path do
        with rails_env: :production do
          execute :rake, 'import:documents', 'filepath=~/vali_subset.txt'
        end
      end
    end
  end

end

