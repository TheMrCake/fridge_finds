import gleam/int
import gleam/list
import gleam/option.{None, Some}
import lustre/attribute.{class}
import lustre/element.{type Element}
import lustre/element/html.{a, div, h1, h2, i, nav, p, section, text}
import lustre/event

// Local includes
import types.{
  type Model, type Msg, type Summary, type TableKind, CategoryTable, Home,
  Navigate, RecipePage, RecipeTable, UserPage, UserTable,
}

pub fn view(model: Model) -> Element(Msg) {
  div([class("app-container")], [
    render_navbar(),
    case model.page {
      Home -> div([], [render_hero(), render_grid(model.summaries)])
      RecipePage(_, _) -> render_detail_page(model)
      UserPage(_, _) -> render_detail_page(model)
      _ -> render_page_not_found()
    },
  ])
}

fn render_navbar() -> Element(Msg) {
  nav([class("navbar")], [
    a([class("logo"), event.on_click(Navigate(Home))], [text("FridgeFinds")]),
    div([class("nav-links")], [text("Login / Register")]),
  ])
}

fn render_hero() -> Element(Msg) {
  section([class("hero")], [h1([], [text("Recipes for You")])])
}

fn render_grid(grid_list: List(Summary)) -> Element(Msg) {
  div([class("summary-grid")], list.map(grid_list, render_summary))
}

fn render_summary(summary: Summary) -> Element(Msg) {
  let target_page = case summary.kind {
    RecipeTable -> RecipePage(summary.id, None)
    UserTable -> UserPage(summary.id, None)
    CategoryTable -> todo
  }

  div([class("summary-card"), event.on_click(Navigate(target_page))], [
    div([class("card-content")], [
      h2([], [text(summary.name)]),
      p([], [text(summary.description)]),
      div([class("badge")], [text(types.table_kind_to_string(summary.kind))]),
    ]),
  ])
}

fn render_loading_state(table_kind: TableKind, id: Int) -> Element(Msg) {
  section([class("detail-view")], [
    h1([], [
      text(types.table_kind_to_string(table_kind) <> " #" <> int.to_string(id)),
    ]),
    p([class("loader")], [text("Fetching details from the API...")]),
    back_button(),
  ])
}

fn render_recipe_view(recipe: types.Recipe) -> Element(Msg) {
  section([class("detail-view")], [
    h1([], [text(recipe.name)]),
    p([class("meta")], [
      text("Prep time: " <> int.to_string(recipe.prep_time_mins) <> " mins"),
    ]),
    div([class("description")], [text(recipe.description)]),
    h2([], [text("Instructions")]),
    p([class("instructions")], [text(recipe.instructions)]),
    back_button(),
  ])
}

fn render_user_view(user: types.User) -> Element(Msg) {
  section([class("detail-view profile")], [
    h1([], [text(user.name)]),
    p([class("bio")], [text(user.description)]),
    i([], [text("User ID: " <> int.to_string(user.id))]),
    back_button(),
  ])
}

fn back_button() -> Element(Msg) {
  a([class("back-btn"), event.on_click(Navigate(Home))], [
    text("← Back to Feed"),
  ])
}

fn render_detail_page(model: Model) -> Element(Msg) {
  case model.page {
    RecipePage(id, data) -> {
      case data {
        None -> render_loading_state(RecipeTable, id)
        Some(recipe) -> render_recipe_view(recipe)
      }
    }

    UserPage(id, data) -> {
      case data {
        None -> render_loading_state(UserTable, id)
        Some(user) -> render_user_view(user)
      }
    }

    _ -> render_page_not_found()
  }
}

fn render_page_not_found() -> Element(Msg) {
  section([class("detail-view")], [
    h1([], [text("Uh oh, looks like that page doesn't exist!")]),
    a([class("back-btn"), event.on_click(Navigate(Home))], [
      text("← Back to Feed"),
    ]),
  ])
}
