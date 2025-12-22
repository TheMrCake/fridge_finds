import gleam/int
import gleam/json
import gleam/list
import gleam/uri

import lustre/effect.{type Effect}
import lustre_http

import plinth/browser/window

import types.{
  type Msg, type TableKind, ApiLoggedIn, ApiLoggedOut, ApiReturnedDetail,
  ApiReturnedSummaries,
}

fn get_origin() -> String {
  window.origin()
}

fn url_builder(args: List(String)) -> String {
  let fold_fn = fn(acc: String, arg: String) -> String { acc <> "/" <> arg }
  get_origin() <> list.fold(args, "/api", fold_fn)
}

pub fn get_recipes_for_you() -> Effect(Msg) {
  let url = url_builder(["recipes-for-you"])
  lustre_http.get(
    url,
    lustre_http.expect_json(types.summaries_decoder(), ApiReturnedSummaries),
  )
}

pub fn get_item_details(id: Int, table_kind: TableKind) -> Effect(Msg) {
  let table_str = types.table_kind_to_string(table_kind)
  let url = url_builder([table_str, int.to_string(id)])

  lustre_http.get(
    url,
    lustre_http.expect_json(types.detail_decoder(table_kind), ApiReturnedDetail),
  )
}

pub fn search(search_str: String) -> Effect(Msg) {
  let url = url_builder(["search"]) <> "?q=" <> uri.percent_encode(search_str)
  lustre_http.get(
    url,
    lustre_http.expect_json(types.summaries_decoder(), ApiReturnedSummaries),
  )
}

pub fn login(username: String, password: String) -> Effect(Msg) {
  let url = url_builder(["login"])
  let user_json =
    json.object([
      #("username", json.string(username)),
      #("password", json.string(password)),
    ])
  lustre_http.post(
    url,
    user_json,
    lustre_http.expect_json(types.user_decoder(), ApiLoggedIn),
  )
}

pub fn session_login() -> Effect(Msg) {
  let url = url_builder(["me"])
  lustre_http.get(
    url,
    lustre_http.expect_json(types.user_decoder(), ApiLoggedIn),
  )
}

pub fn logout() -> Effect(Msg) {
  let url = url_builder(["logout"])
  lustre_http.get(url, lustre_http.expect_anything(ApiLoggedOut))
}
