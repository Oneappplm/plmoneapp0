#!/usr/bin/env ruby

puts `git checkout master && git pull origin master --rebase`
puts `git fetch origin hvhs-app && git checkout hvhs-app && git rebase master && git push	origin hvhs-app -f`
puts `git fetch origin qualifacts-app && git checkout qualifacts-app && git rebase master && git push origin qualifacts-app -f`
puts `git fetch origin staging && git checkout staging && git rebase master && git push origin staging -f`
puts `git checkout master && git push origin master`