#!/usr/bin/env ruby

puts `git as -av`
puts `git checkout hvhs-app && git push	origin hvhs-app &&	git push zcorp hvhs-app`
puts `git checkout qualifacts-app && git push origin qualifacts-app && git push zcorp qualifacts-app`
puts `git checkout staging && git push origin staging && git push zcorp staging`
puts `git checkout master && git push origin master && git push zcorp master && git push heroku master`