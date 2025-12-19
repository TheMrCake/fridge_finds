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
  type Model, type Msg, type Page, ApiReturnedDetail, ApiReturnedSummaries, Home,
  Model, Navigate, OnUrlChange, RecipeDetail, RecipePage, RecipeTable,
  UserDetail, UserPage, UserTable,
}

fn page_to_effect(page: Page) -> Effect(Msg) {
  case page {
    Home -> api.get_recipes_for_you()
    RecipePage(id, None) -> api.get_item_details(id, RecipeTable)
    UserPage(id, None) -> api.get_item_details(id, UserTable)
    _ -> effect.none()
  }
}

pub fn init(_flags) -> #(Model, Effect(Msg)) {
  let initial_page =
    modem.initial_uri()
    |> result.map(router.route_from_uri)
    |> result.unwrap(Home)

  #(
    Model(..types.default_model(), page: initial_page),
    effect.batch([modem.init(OnUrlChange), api.get_recipes_for_you()]),
  )
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    Navigate(page) -> {
      let effect = page_to_effect(page)
      let route = router.route_from_page(page)
      #(
        Model(..model, page: page),
        effect.batch([effect, modem.push(route, None, None)]),
      )
    }

    OnUrlChange(uri) -> {
      let page = router.route_from_uri(uri)
      // Need to reload the information if going back to a recipe or user
      let effect = page_to_effect(page)
      #(Model(..model, page: router.route_from_uri(uri)), effect)
    }

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
  }
}
