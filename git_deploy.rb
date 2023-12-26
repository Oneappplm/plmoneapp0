  #!/usr/bin/env ruby

puts `git checkout master && git pull origin master --rebase`
puts `git fetch origin hvhs-app && git checkout hvhs-app && git rebase master && git push	origin hvhs-app`
puts `git fetch origin qualifacts-app && git checkout qualifacts-app && git rebase master && git push origin qualifacts-app`
puts `git fetch origin qualifacts-demo && git checkout qualifacts-demo && git rebase qualifacts-app && git push origin qualifacts-demo`
puts `git fetch origin qualifacts-app-heroku && git checkout qualifacts-app-heroku && git rebase master && git push origin qualifacts-app-heroku`
puts `git fetch origin dcs-app && git checkout dcs-app && git rebase master && git push origin dcs-app`
puts `git fetch origin dcs-demo && git checkout dcs-demo && git rebase dcs-app && git push origin dcs-demo`
puts `git fetch origin metlife-app && git checkout metlife-app && git rebase master && git push origin metlife-app`
puts `git checkout master && git push origin master`