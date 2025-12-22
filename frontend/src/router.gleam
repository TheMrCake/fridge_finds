import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/uri.{type Uri}

// Local includes
import types.{
  type Page, type Route, Home, LoginPage, PageNotFound, RecipePage, RegisterPage,
  Route, SearchPage, UserPage, default_route,
}

pub fn route_from_uri(cur_uri: Uri) -> Page {
  // Seperate query from path

  let cur_segments = uri.path_segments(cur_uri.path)
  let cur_query =
    option.unwrap(cur_uri.query, "")
    |> uri.parse_query
    |> result.unwrap([])
    |> list.key_find("q")
    |> result.unwrap("")

  case cur_segments, cur_query {
    [], _ -> Home
    ["recipes", id_string], _ -> {
      case int.parse(id_string) {
        Ok(id) -> RecipePage(id:, recipe: None)
        Error(_) -> PageNotFound
      }
    }
    ["users", id_string], _ -> {
      case int.parse(id_string) {
        Ok(id) -> UserPage(id:, user: None)
        Error(_) -> PageNotFound
      }
    }
    ["search"], query -> SearchPage(query)
    ["login"], _ -> LoginPage("", "")
    _, _ -> {
      PageNotFound
    }
  }
}

pub fn route_from_page(page: Page) -> Route {
  case page {
    Home -> Route(..default_route(), path: "/")
    RecipePage(id, _) ->
      Route(..default_route(), path: "/recipes/" <> int.to_string(id))
    UserPage(id, _) ->
      Route(..default_route(), path: "/users/" <> int.to_string(id))
    SearchPage(query) ->
      Route(
        ..default_route(),
        path: "/search",
        query: Some("q=" <> uri.percent_encode(query)),
      )
    LoginPage(_, _) -> Route(..default_route(), path: "/login")
    RegisterPage(_, _) -> Route(..default_route(), path: "/register")
    PageNotFound -> Route(..default_route(), path: "/404")
  }
}
