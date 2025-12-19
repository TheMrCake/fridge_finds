import gleam/dynamic/decode
import gleam/option.{type Option}
import gleam/uri.{type Uri}
import lustre_http.{type HttpError}

pub type AppError {
  UnknownTable
}

pub type Page {
  Home
  RecipePage(id: Int, recipe: Option(Recipe))
  UserPage(id: Int, user: Option(User))
  PageNotFound
}

pub type TableKind {
  RecipeTable
  UserTable
  CategoryTable
}

pub type Recipe {
  Recipe(
    id: Int,
    name: String,
    description: String,
    instructions: String,
    prep_time_mins: Int,
    author_id: Int,
  )
}

pub type User {
  User(id: Int, name: String, description: String)
}

pub type Category {
  Category(id: Int, name: String, description: String)
}

pub fn table_kind_to_string(table_kind: TableKind) -> String {
  case table_kind {
    RecipeTable -> "recipes"
    UserTable -> "users"
    CategoryTable -> "categories"
  }
}

pub fn string_to_table_kind(
  table_kind_str: String,
) -> Result(TableKind, AppError) {
  case table_kind_str {
    "recipes" -> Ok(RecipeTable)
    "users" -> Ok(UserTable)
    "categories" -> Ok(CategoryTable)
    _ -> Error(UnknownTable)
  }
}

pub fn table_kind_decoder() -> decode.Decoder(TableKind) {
  use decoded_string <- decode.then(decode.string)
  case string_to_table_kind(decoded_string) {
    Ok(table_kind) -> decode.success(table_kind)
    _ -> decode.failure(RecipeTable, expected: "TableKind")
  }
}

pub type Summary {
  Summary(id: Int, kind: TableKind, name: String, description: String)
}

pub fn summary_decoder() -> decode.Decoder(Summary) {
  use id <- decode.field("id", decode.int)
  use kind <- decode.field("kind", table_kind_decoder())
  use name <- decode.field("name", decode.string)
  use description <- decode.field("description", decode.string)

  decode.success(Summary(id:, kind:, name:, description:))
}

pub fn summaries_decoder() -> decode.Decoder(List(Summary)) {
  decode.list(summary_decoder())
}

pub type Detail {
  RecipeDetail(Recipe)
  UserDetail(User)
  CategoryDetail(Category)
}

pub fn detail_decoder(table_kind: TableKind) -> decode.Decoder(Detail) {
  use id <- decode.field("id", decode.int)
  use name <- decode.field("name", decode.string)
  use description <- decode.field("description", decode.string)
  case table_kind {
    UserTable -> decode.success(UserDetail(User(id:, name:, description:)))
    CategoryTable ->
      decode.success(CategoryDetail(Category(id:, name:, description:)))
    RecipeTable -> {
      use instructions <- decode.field("instructions", decode.string)
      use prep_time_mins <- decode.field("prep_time_mins", decode.int)
      use author_id <- decode.field("author_id", decode.int)

      decode.success(
        RecipeDetail(Recipe(
          id:,
          name:,
          description:,
          instructions:,
          prep_time_mins:,
          author_id:,
        )),
      )
    }
  }
}

pub type Msg {
  Navigate(Page)
  OnUrlChange(Uri)

  // API Msgs
  ApiReturnedSummaries(Result(List(Summary), HttpError))
  ApiReturnedDetail(Result(Detail, HttpError))
}

pub type Model {
  Model(page: Page, search_input: String, summaries: List(Summary))
}

pub fn default_model() -> Model {
  Model(page: Home, search_input: "", summaries: [])
}
