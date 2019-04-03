# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

## Deployment instructions

### Setup git remotes (One time only):

    git remote add staging git@heroku.com:convoter-staging.git
    git remote add production git@heroku.com:convoter.git

### Deploy to [staging](https://convoter-staging.herokuapp.com)
    git push staging master
    heroku run bin/rails db:migrate --app convoter-staging # if needed

### Deploy to [production](https://convoter.com)
    git push production master
    heroku run bin/rails db:migrate --app convoter # if needed

Because this app uses a [Heroku review app pipeline](https://dashboard.heroku.com/pipelines/18339062-de2b-469a-99c4-2d68be4d139f), you can open a pull request to generate an app for testing purposes.
