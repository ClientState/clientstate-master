{assert} = require "chai"
Promise = require "bluebird"

models = {
  User
  ProviderLoginDetails
} = require "../models"

github_complete = require("../oauth-events").github_complete

github_result = {
  data: {
    access_token: 'abcdef',
    token_type: 'bearer',
    scope: ''
  },
  status: 'success',
  state: 'qwerty',
  provider: 'github',
  user_data: {
    login: 'skyl',
    id: 61438,
    avatar_url: 'https://avatars.githubusercontent.com/u/61438?v=2',
    gravatar_id: '',
    url: 'https://api.github.com/users/skyl',
    html_url: 'https://github.com/skyl',
    followers_url: 'https://api.github.com/users/skyl/followers',
    following_url: 'https://api.github.com/users/skyl/following{/other_user}',
    gists_url: 'https://api.github.com/users/skyl/gists{/gist_id}',
    starred_url: 'https://api.github.com/users/skyl/starred{/owner}{/repo}',
    subscriptions_url: 'https://api.github.com/users/skyl/subscriptions',
    organizations_url: 'https://api.github.com/users/skyl/orgs',
    repos_url: 'https://api.github.com/users/skyl/repos',
    events_url: 'https://api.github.com/users/skyl/events{/privacy}',
    received_events_url: 'https://api.github.com/users/skyl/received_events',
    type: 'User',
    site_admin: false,
    name: 'Skylar Saveland',
    company: 'JPMorgan Chase',
    blog: 'http://skyl.org/',
    location: 'San Francisco',
    email: 'skylar.saveland@gmail.com',
    hireable: true,
    bio: null,
    public_repos: 104,
    public_gists: 31,
    followers: 57,
    following: 128,
    created_at: '2009-03-09T01:41:19Z',
    updated_at: '2014-10-17T23:41:51Z'
  }
}


beforeEach (done) ->
  # http://stackoverflow.com/a/18060545/177293
  knexion.raw(
    "TRUNCATE TABLE #{(v.tableName for k,v of models).join(',')} RESTART IDENTITY"
  ).then done()


describe 'Github Oauth Complete', () ->

  it 'Users are empty', (done) ->
    # just convincing myself that things are working
    (new User()).fetchAll().then (collection) ->
      assert collection.length is 0
      done()

  it 'Create new User with new login details', (done) ->
    p = Promise.resolve(github_complete(github_result))
    p.then () ->
      (new User(id: 1)).logins().fetch().then (logins) ->
        assert logins.models[0].id is '61438'
        done()

  it 'Called multiple times - no error, 1 user with 1 PLD', (done) ->
    p = Promise.resolve github_complete github_result
    p.then () ->
      p2 = Promise.resolve github_complete github_result
      p2.then () ->
        (new User()).fetchAll().then (collection) ->
          assert collection.length is 1
          collection.models[0].logins().fetch().then (logins) ->
            assert logins.length is 1
            done()

  it 'Called simulatneously, causes rollback, 1 user - 1 PLD', (done) ->
    p = Promise.resolve github_complete github_result
    p2 = Promise.resolve github_complete github_result
    p2.then (err) ->
      assert err.detail is 'Key (id)=(61438) already exists.'
      (new User()).fetchAll().then (collection) ->
        assert collection.length is 1
        collection.models[0].logins().fetch().then (logins) ->
          assert logins.length is 1
          done()

