


## PLMHEALTHONEPP

Ruby Version: **3.0.2**
Rails Version: **7.0.4.2**
Bundler Version: **2.4.12**
Rbenv Version: **1.2.0**
Database: **postgres (PostgreSQL) 15.3**

**Setup:**

 1. Install ruby using rbenv
 2. bundle install

**Rake Tasks Setup:**

     - rake db:reset
     - rake db:migrate
     - rake plmhealthoneapp:seed_initial_data
     - rake 'plmhealthoneapp:update_client_name[plmhealthoneapp]' - plm instance (default)
     - rake 'plmhealthoneapp:update_client_name[qualifacts]' - qualifacts instance (other option)
     - rake plmhealthoneapp:create_default_accounts - creating default accounts

**Start Local Server:**

     - rails s

**Deployment**

    run: ruby git_deploy.rb

list of branches for automated rebasing and push:

 - hvhs-app
 - qualifacts-app
 - qualifacts-app-heroku
 - staging
 - master

> we have **dev** branch for testing our working branch.  everytime you
> push those branch on live, it will autodeploy on the server.
> You can wait 2 - 3 minutes before checking on live.

List of domains with corresponding branches

 - https://plmhealth.net/ - master branch (main app)
 - https://dev.plmhealth.net/ - dev branch (for developers | testing)
 - https://qualifacts.plmhealth.net/ - qualifacts-app branch (main app)
 - https://demo.plmhealth.net/ - staging branch (for QA | testing)
 - https://qualifacts-06a6ed193a78.herokuapp.com/ - qualifacts-app-heroku branch ( for QA | testing)

**Task Workflow:**

 1. Create new branch againsts master branch for your task
 2. after done on development, create a PR request
 3. make sure your commits is only 1, if more than one, use rebase squashing method: **git rebase -i HEAD~{number_of_commits}**
 4. When testing on dev instance, use **git cherry-pick {commit_hash}** command.
 5. When done, create a short demo of your task or attach snapshots.
 6. After your PR is approved. you can execute deploy script. **ruby git_deploy.rb**
