import lustre
import state.{init, update}
import ui.{view}

pub fn main() {
  let app = lustre.application(init, update, view)
  lustre.start(app, "#app", Nil)
}
