import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute.{class, placeholder, type_, value}
import lustre/element.{type Element}
import lustre/element/html.{
  button, div, h1, h2, i, input, label, nav, p, section, span, text,
}
import lustre/event.{on_input}

// Local includes
import types.{
  type Model, type Msg, type Page, type Summary, type TableKind, type User,
  CategoryTable, Home, LoginPage, NavBack, NavTo, PageNotFound, RecipePage,
  RecipeTable, RegisterPage, SearchPage, UserClickedLogout, UserPage,
  UserSubmittedAuth, UserTable, UserUpdatedPassword, UserUpdatedSearch,
  UserUpdatedUsername,
}

pub fn view(model: Model) -> Element(Msg) {
  div([class("app-container")], [
    render_navbar(model.page, model.current_user),
    case model.page {
      Home ->
        div([], [
          render_hero("Recipes for You!"),
          render_grid(model.summaries),
        ])
      RecipePage(_, _) -> render_detail_page(model.page)
      UserPage(_, _) -> render_detail_page(model.page)
      SearchPage(_) -> {
        div([], [
          render_hero("Search Results"),
          render_grid(model.summaries),
        ])
      }
      LoginPage(username, password) -> render_login_page(username, password)
      RegisterPage(username, password) ->
        render_register_page(username, password)
      PageNotFound -> render_page_not_found()
    },
  ])
}

fn render_navbar(page: Page, user_opt: Option(User)) -> Element(Msg) {
  nav([class("navbar")], [
    button([class("logo"), event.on_click(NavTo(Home))], [
      text("FridgeFinds"),
    ]),

    render_search_bar(page),
    div([class("nav-links")], case user_opt {
      Some(user) -> [
        span([class("user-greeting")], [text("Hi, " <> user.name)]),
        button([class("btn-secondary"), event.on_click(UserClickedLogout)], [
          text("Sign Out"),
        ]),
      ]
      None -> [
        button([class("btn-link"), event.on_click(NavTo(LoginPage("", "")))], [
          text("Login"),
        ]),
        button(
          [class("btn-primary"), event.on_click(NavTo(RegisterPage("", "")))],
          [
            text("Register"),
          ],
        ),
      ]
    }),
  ])
}

fn render_hero(hero_text: String) -> Element(Msg) {
  section([class("hero")], [h1([], [text(hero_text)])])
}

fn render_grid(grid_list: List(Summary)) -> Element(Msg) {
  div([class("summary-grid")], list.map(grid_list, render_summary))
}

fn render_search_bar(page: Page) -> Element(Msg) {
  div([class("search-container")], [
    input([
      type_("text"),
      placeholder("Search recipes..."),
      value(case page {
        SearchPage(query) -> {
          query
        }
        _ -> ""
      }),
      on_input(UserUpdatedSearch),
    ]),
  ])
}

fn render_summary(summary: Summary) -> Element(Msg) {
  let target_page = case summary.kind {
    RecipeTable -> RecipePage(summary.id, None)
    UserTable -> UserPage(summary.id, None)
    CategoryTable -> PageNotFound
  }

  div([class("summary-card"), event.on_click(NavTo(target_page))], [
    div([class("card-content")], [
      h2([], [text(summary.name)]),
      p([], [text(summary.description)]),
      div([class("badge")], [text(types.table_kind_to_string(summary.kind))]),
    ]),
  ])
}

fn render_loading_state(table_kind: TableKind, id: Int) -> Element(Msg) {
  // section([class("detail-view")], [
  //   h1([], [
  //     text(types.table_kind_to_string(table_kind) <> " #" <> int.to_string(id)),
  //   ]),
  //   p([class("loader")], [text("Fetching details from the API...")]),
  //   back_button(),
  // ]) Make this better
  div([], [])
}

fn render_recipe_detail(recipe: types.Recipe) -> Element(Msg) {
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

fn render_user_detail(user: types.User) -> Element(Msg) {
  section([class("detail-view profile")], [
    h1([], [text(user.name)]),
    p([class("bio")], [text(user.description)]),
    i([], [text("User ID: " <> int.to_string(user.id))]),
    back_button(),
  ])
}

fn back_button() -> Element(Msg) {
  button([class("back-btn"), event.on_click(NavBack)], [
    text("← Back"),
  ])
}

fn render_detail_page(page: Page) -> Element(Msg) {
  case page {
    RecipePage(id, data) -> {
      case data {
        None -> render_loading_state(RecipeTable, id)
        Some(recipe) -> render_recipe_detail(recipe)
      }
    }

    UserPage(id, data) -> {
      case data {
        None -> render_loading_state(UserTable, id)
        Some(user) -> render_user_detail(user)
      }
    }

    _ -> render_page_not_found()
  }
}

fn render_login_page(username: String, password: String) -> Element(Msg) {
  div([class("auth-container")], [
    h2([], [text("Welcome Back")]),

    div([class("form-group")], [
      label([], [text("Username")]),
      input([
        type_("text"),
        placeholder("Enter username"),
        value(username),
        on_input(UserUpdatedUsername),
      ]),
    ]),

    div([class("form-group")], [
      label([], [text("Password")]),
      input([
        type_("password"),
        placeholder("Enter password"),
        value(password),
        on_input(UserUpdatedPassword),
      ]),
    ]),

    button([class("btn-primary"), event.on_click(UserSubmittedAuth)], [
      text("Login"),
    ]),

    p([], [
      text("Don't have an account? "),
      button([class("back-btn"), event.on_click(NavBack)], [
        text("Register here"),
      ]),
    ]),
  ])
}

fn render_register_page(username: String, password: String) -> Element(Msg) {
  todo
}

fn render_page_not_found() -> Element(Msg) {
  section([class("detail-view")], [
    h1([], [text("Uh oh, looks like that page doesn't exist!")]),
    back_button(),
  ])
}
