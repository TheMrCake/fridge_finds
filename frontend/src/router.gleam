import gleam/int
import gleam/option.{None}
import gleam/uri.{type Uri}

// Local includes
import types.{type Page, Home, PageNotFound, RecipePage, UserPage}

pub fn route_from_uri(uri: Uri) -> Page {
  case uri.path_segments(uri.path) {
    [] -> Home
    ["recipes", id_string] -> {
      case int.parse(id_string) {
        Ok(id) -> RecipePage(id:, recipe: None)
        Error(_) -> PageNotFound
      }
    }
    ["users", id_string] -> {
      case int.parse(id_string) {
        Ok(id) -> UserPage(id:, user: None)
        Error(_) -> PageNotFound
      }
    }
    _ -> PageNotFound
  }
}

pub fn route_from_page(page: Page) -> String {
  case page {
    Home -> "/"
    RecipePage(id, _) -> "/recipes/" <> int.to_string(id)
    UserPage(id, _) -> "/users/" <> int.to_string(id)
    PageNotFound -> "/404"
  }
}
