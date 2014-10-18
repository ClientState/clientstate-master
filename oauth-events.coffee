# global.bookshelf, for now
{
  User
  ProviderLoginDetails
} = require "./models"



github_complete = (result) ->
  trans = bookshelf.transaction (t) ->
    uid = result.user_data.id

    model =
      id: uid
      provider: "github"

    new ProviderLoginDetails(model).fetch(null, transaction: t).then (m) ->
      if m is null
        # new ProviderLoginDetails
        # are we logged in as someone else?
        # TODO: add github to user who is logged in with $OTHER_OAUTH
        # instead of just assuming that we create a new user
        user = new User()
        user.save(null, method: "insert", transacting: t).then (user) ->
          model.user_id = user.id
          pld = new ProviderLoginDetails model
          pld.save({data: result.user_data}, {method: "insert", transacting: t}).then () ->
            return
      else
        return

  trans.catch (err) ->
    # somehow this gets returned to the resolved promise
    # whereas, the TX seems to get returned in the other cases.
    return err


module.exports.github_complete = github_complete
