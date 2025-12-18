import lustre/attribute.{class}
import lustre/element.{type Element}
import lustre/element/html.{div, h1, nav, section, text}
import types.{type Model}

pub fn view(model: Model) -> Element(msg) {
  div([], [render_navbar(), render_hero(), render_categories()])
}

fn render_navbar() -> Element(msg) {
  nav([class("navbar")], [
    div([class("logo")], [text("FridgeFinds")]),
    div([class("nav-links")], [text("Login / Register")]),
  ])
}

fn render_hero() -> Element(msg) {
  section(
    [attribute.styles([#("padding", "60px 20px"), #("text-align", "center")])],
    [h1([], [text("What's in your fridge today?")])],
  )
}

fn render_categories() -> Element(msg) {
  div([class("category-grid")], [
    category_item("Vegetables"),
    category_item("Fruits"),
    category_item("Dairy"),
    category_item("Meat"),
  ])
}

fn category_item(name: String) -> Element(msg) {
  div([class("category-card")], [text(name)])
}
