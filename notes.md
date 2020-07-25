- Convert all class properties that are `logger`, `serializer` & `transformer` to `Motion.logger` to reduce memory
- `HTMLTransformer#add_state_to_html` only needs the component. Line 21 `fragment = Myhtml::Parser.new(html)` should just pass in `component.render`



# Branch channel-experiment
- instead of passing channel to components, create a channel interface/api object & pass that in