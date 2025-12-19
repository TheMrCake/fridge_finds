import gleam/int
import gleam/list

import lustre/effect.{type Effect}
import lustre_http

import plinth/browser/window

import types.{type Msg, type TableKind, ApiReturnedDetail, ApiReturnedSummaries}

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
