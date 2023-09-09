#!/usr/bin/env ruby

puts `git checkout master && git pull origin master --rebase`
puts `git fetch origin hvhs-app && git checkout hvhs-app && git rebase master && git push	origin hvhs-app`
puts `git fetch origin qualifacts-app && git checkout qualifacts-app && git rebase master && git push origin qualifacts-app`
puts `git fetch origin qualifacts-app-heroku && git checkout qualifacts-app-heroku && git rebase master && git push origin qualifacts-app-heroku`
# puts `git fetch origin staging && git checkout staging && git rebase master && git push origin staging`
puts `git checkout master && git push origin master`