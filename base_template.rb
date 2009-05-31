# Delete unnecessary files
run "rm README"
run "rm doc/README_FOR_APP"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/robots.txt"

generate :nifty_layout

# Init git
git :init
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"

# Set up .gitignore files
run %{find . -type d -empty | xargs -I xxx touch xxx/.gitignore}
file '.gitignore', <<-END
.DS_Store
coverage/*
log/*.log
db/*.db
db/*.sqlite3
db/schema.rb
tmp/**/*
doc/api
doc/app
config/database.yml
coverage/*
END

run "echo 'TODO add readme content' > README"
run "cp config/database.yml config/database.yml.example"

# Install all gems
if yes?("Do you want to use RSpec for testing?")
  plugin "rspec", :git => "git://github.com/dchelimsky/rspec.git"
  plugin "rspec-rails", :git => "git://github.com/dchelimsky/rspec-rails.git"
  generate :rspec
end

if yes?("Do you want to use Shoulda + Factory Girl?")
  plugin 'shoulda', :git => 'git://github.com/thoughtbot/shoulda.git', :submodule => true
  plugin 'factory_girl', :git => 'git://github.com/thoughtbot/factory_girl.git', :submodule => true
end

# Install gems
gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
rake "gems:install"

# Initialize submodules
git :submodule => "init"


# Commit all work so far to the repository
git :add => ".", :commit => "-m 'Initial commit'"


name = ask("What do you want a user to be called?")
generate :nifty_authentication, name
rake "db:migrate"

git :add => ".", :commit => "-m 'adding authentication'"

generate :controller, "welcome index"
route "map.root :controller => 'welcome'"
git :rm => "public/index.html"

git :add => ".", :commit => "-m 'adding welcome controller'"