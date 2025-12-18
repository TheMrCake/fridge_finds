import lustre/effect.{type Effect, none}
import types.{type Model, type Msg, Model}

pub fn init(_flags) -> #(Model, Effect(Msg)) {
  #(Model(""), none())
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  #(model, none())
}
