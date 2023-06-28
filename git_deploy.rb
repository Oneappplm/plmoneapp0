#!/usr/bin/env ruby

puts `git checkout master && git pull master --rebase`
puts `git as -av`
puts `git checkout hvhs-app && git push	hvhs-app &&	git push hvhs-app`
puts `git checkout qualifacts-app && git push qualifacts-app && git push qualifacts-app`
puts `git checkout staging && git push staging && git push staging`
puts `git checkout master && git push master && git push master && git push heroku master`