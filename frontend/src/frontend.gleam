import lustre
import lustre/element/html.{div, h1, text}

pub fn main() {
  let app = lustre.element(div([], [h1([], [text("A gleam hello to you!")])]))
  lustre.start(app, "#app", Nil)
}
