import gleam/io
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import lustre/effect.{type Effect}
import modem
import router

// Local includes
import api
import types.{
  type Model, type Msg, type Page, ApiLoggedIn, ApiLoggedOut, ApiReturnedDetail,
  ApiReturnedSummaries, Home as HomePage, LoginPage, Model, NavBack, NavTo,
  OnUrlChange, RecipeDetail, RecipePage, RecipeTable, RegisterPage, SearchPage,
  UserClickedLogout, UserDetail, UserPage, UserSubmittedAuth, UserTable,
  UserUpdatedPassword, UserUpdatedSearch, UserUpdatedUsername,
}

fn page_to_effect(page: Page) -> Effect(Msg) {
  case page {
    HomePage -> api.get_recipes_for_you()
    RecipePage(id, None) -> api.get_item_details(id, RecipeTable)
    UserPage(id, None) -> api.get_item_details(id, UserTable)
    SearchPage(query) -> api.search(query)
    _ -> effect.none()
  }
}

fn navigate_back() -> Effect(Msg) {
  modem.back(1)
}

pub fn init(_flags) -> #(Model, Effect(Msg)) {
  let initial_page =
    modem.initial_uri()
    |> result.map(router.route_from_uri)
    |> result.unwrap(HomePage)
  let initial_effect = page_to_effect(initial_page)

  #(
    Model(..types.default_model(), page: initial_page),
    effect.batch([modem.init(OnUrlChange), api.session_login(), initial_effect]),
  )
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    // Navigating
    NavTo(page) -> {
      let new_effect = page_to_effect(page)
      let route = router.route_from_page(page)
      #(
        model,
        effect.batch([
          new_effect,
          modem.push(route.path, route.query, route.fragment),
        ]),
      )
    }

    NavBack -> {
      #(model, navigate_back())
    }

    OnUrlChange(uri) -> {
      let page = router.route_from_uri(uri)

      // Need to reload the information if going back to a recipe or user
      let new_effect = page_to_effect(page)

      #(Model(..model, page: page), new_effect)
    }

    // Searching
    UserUpdatedSearch(query) -> {
      let #(page, hidden_page) = case query {
        "" -> #(option.unwrap(model.hidden_page, HomePage), None)
        _ -> #(SearchPage(query), case model.page {
          SearchPage(_) -> model.hidden_page
          _ -> Some(model.page)
        })
      }

      let route = router.route_from_page(page)
      #(
        Model(..model, hidden_page:),
        modem.replace(route.path, route.query, route.fragment),
      )
    }

    // Logingin and Registering
    UserUpdatedUsername(username) -> {
      #(
        Model(..model, page: case model.page {
          LoginPage(_, password) -> LoginPage(username, password)
          RegisterPage(_, password) -> RegisterPage(username, password)
          _ -> model.page
        }),
        effect.none(),
      )
    }

    UserUpdatedPassword(password) -> {
      #(
        Model(..model, page: case model.page {
          LoginPage(username, _) -> LoginPage(username, password)
          RegisterPage(username, _) -> RegisterPage(username, password)
          _ -> model.page
        }),
        effect.none(),
      )
    }

    UserSubmittedAuth -> {
      case model.page {
        LoginPage(username, password) -> #(model, api.login(username, password))
        RegisterPage(username, password) -> #(
          model,
          api.login(username, password),
        )
        _ -> #(model, effect.none())
      }
    }

    UserClickedLogout -> {
      #(model, api.logout())
    }

    // API calls
    ApiReturnedSummaries(result) -> {
      case result {
        Ok(summaries) -> #(Model(..model, summaries:), effect.none())
        Error(e) -> {
          io.println("API error: " <> string.inspect(e))
          #(model, effect.none())
        }
      }
    }

    ApiReturnedDetail(result) -> {
      case result {
        Ok(detail) -> {
          let updated_page = case model.page, detail {
            RecipePage(id, _), RecipeDetail(recipe) ->
              RecipePage(id, Some(recipe))
            UserPage(id, _), UserDetail(user) -> UserPage(id, Some(user))
            current_page, _ -> current_page
          }

          #(Model(..model, page: updated_page), effect.none())
        }
        Error(e) -> {
          io.println("API error: " <> string.inspect(e))
          #(model, effect.none())
        }
      }
    }

    ApiLoggedIn(result) -> {
      case result {
        Ok(user) -> {
          #(Model(..model, current_user: Some(user)), navigate_back())
        }
        Error(e) -> {
          io.println("API error: " <> string.inspect(e))
          #(model, effect.none())
        }
      }
    }

    ApiLoggedOut(result) -> {
      case result {
        Ok(_) -> {
          #(Model(..model, current_user: None), effect.none())
        }
        Error(e) -> {
          io.println("API error: " <> string.inspect(e))
          #(model, effect.none())
        }
      }
    }
  }
}
