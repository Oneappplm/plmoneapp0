#!/usr/bin/env ruby

puts `git checkout origin master && git pull origin master --rebase`
puts `git as -av`
puts `git checkout hvhs-app && git push	origin hvhs-app &&	git push origin hvhs-app`
puts `git checkout qualifacts-app && git push origin qualifacts-app && git push origin qualifacts-app`
puts `git checkout staging && git push origin staging && git push origin staging`
puts `git checkout master && git push origin master && git push origin master && git push heroku master`