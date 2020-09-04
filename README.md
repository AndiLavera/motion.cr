[![Codacy Badge](https://app.codacy.com/project/badge/Grade/91df8833c8fd48b3a0397bf51e2c3787)](https://www.codacy.com/manual/andrewc910/motion.cr?utm_source=github.com&utm_medium=referral&utm_content=andrewc910/motion.cr&utm_campaign=Badge_Grade)

![Build](https://github.com/andrewc910/motion.cr/workflows/CI/badge.svg)

![Docs](https://github.com/andrewc910/motion.cr/workflows/Build%20Docs%20and%20Deploy/badge.svg)

![dev](https://img.shields.io/david/dev/andrewc910/motion.cr)

<p align="center">
  <!-- <img src="https://raw.githubusercontent.com/veelenga/bin/master/ameba/logo.png" width="800"> -->
  <h3 align="center">Motion</h3>
  <p align="center">Reactive, Real-time Frontend Components<p>
  <p align="center">
    <a href="https://www.codacy.com/manual/andrewc910/motion.cr?utm_source=github.com&utm_medium=referral&utm_content=andrewc910/motion.cr&utm_campaign=Badge_Grade"><img src="https://app.codacy.com/project/badge/Grade/91df8833c8fd48b3a0397bf51e2c3787"></a>
    <a href="https://github.com/andrewc910/motion.cr/releases"><img src="https://img.shields.io/github/release/andrewc910/motion.cr.svg?maxAge=360"></a>
    <a href="https://github.com/andrewc910/motion.cr/blob/master/LICENSE"><img src="https://img.shields.io/github/license/andrewc910/motion.cr.svg"></a>
    <a href="#"><img src="https://github.com/andrewc910/motion.cr/workflows/CI/badge.svg"></a>
    <a href="#"><img src="https://github.com/andrewc910/motion.cr/workflows/Build%20Docs%20and%20Deploy/badge.svg"></a>
  </p>
</p>

<p align="center">
  <a href="http://3.23.28.58/">Try the Motion Demo</a>
</p>

<p align="center"> 
  <img src="./images/motion-calculator.gif" width="450" />
</p>

Motion is a framework for building reactive, real-time frontend UI components in your Amber application using pure Crystal that are reusable, testable & encapsulated. For brevity, we will call them MotionComponents.

- Motion is an Object-Oriented View Layer
- Plays nicely with the Amber monolith you have.
- Peacefully coexists with your existing frontend
- Real-time frontend UI updates from frontend user interaction AND server-side updates.
- No more frontend models, stores, or syncing; your source of truth is the database you already have.
- **No JavaScript required!**

## Table of Contents

- [Motion.cr](#motioncr)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Documentation](#documentation)
  - [Component Guide](#component-guide)
    - [Why should I use components?](#why-should-i-use-components-)
      - [Testing](#testing)
      - [Data Flow](#data-flow)
      - [Standards](#standards)
    - [Building components](#building-components)
      - [Conventions](#conventions)
      - [Quick start](#quick-start)
      - [HTML Generation](#html-generation)
      - [Props & Type Safety](#props---type-safety)
      - [Blocks & Procs](#blocks---procs)
  - [Motion Guide](#motion-guide)
    - [Installation](#installation-1)
    - [Building Motions](#building-motions)
      - [Frontend interactions](#frontend-interactions)
      - [Motion::Event and Motion::Element](#motionevent-and-motionelement)
  - [Limitations](#limitations)
  - [Roadmap](#roadmap)
  - [Contributing](#contributing)
  - [License](#license)

## Installation

Motion.cr has Crystal and JavaScript parts, execute both of these commands:

```sh
dependencies:
  motion.cr:
    github: andrewc910/motion.cr
```

Create a file `motion.cr` in `config/initializers` and add:

```crystal
require "motion"
# The next require adds the `render` method for components to Amber controllers
require "motion/amber/monkey_patch"
```

## Documentation

- [API Documentation](https://andrewc910.github.io/motion.cr/)

## Component Guide

MotionComponents are Crystal objects that output HTML. MotionComponents are most effective in cases where view code is reused or benefits from being tested directly. The code itself was pulled & altered from [Lucky Framework](https://github.com/luckyframework/lucky).

### Why should I use components?

#### Testing

Unlike traditional views, Motion Components can be unit-tested.

Views are typically tested with slow integration tests that also exercise the routing and controller layers in addition to the view. This cost often discourages thorough test coverage.

With MotionComponents, integration tests can be reserved for end-to-end assertions, with permutations and corner cases covered at the unit level.

#### Data Flow

Traditional views have an implicit interface, making it hard to reason about what information is needed to render, leading to subtle bugs when rendering the same view in different contexts.

MotionComponents use defined props that clearly defines what is needed to render, making them easier (and safer) to reuse than partials.

#### Standards

Views often fail basic code quality standards: long methods, deep conditional nesting, and mystery guests abound.

MotionComponents are Crystal objects, making it easy to follow (and enforce) code quality standards.

### Building components

#### Conventions

Components are subclasses of `Motion::Base` and live in `views/components`. It's common practice to create and inherit from an `ApplicationComponent` that is a subclass of `Motion::Base`. By doing so, not only can you share logic, you can share view templates.

Component names end in `Component`.

Component module names are plural, as for controllers and jobs: `Users::AvatarComponent`

#### Quick start

If you followed the installation guide above, you can start with you first component.

1. Create a `components` folder in `views`
2. Create your first component:

```crystal
class MyFirstComponent < Motion::Base
  def render
    html_doctype
    head do
      css_link "/css/main.css"
      utf8_charset
      meta content: "text/html;charset=utf-8", http_equiv: "Content-Type"
      title "My First Component"
    end

    body do
      h1 { "My First Component!" }
    end
  end
end
```

3. Render it in your controller:

```crystal
render MyFirstComponent
```

#### HTML Generation

For static html rendering, please review the [lucky framework documentation](https://www.luckyframework.org/guides/frontend/rendering-html#layouts)

> Note: Lucky uses the macro keyword `needs`, motion uses `prop`

#### Props & Type Safety

Props allow you to pass arguements to child components that are type safe. One of the problems with ecr views & partials is, it's hard to reason what variables & data the page requires to render because everything is within scope. Props explicity display what is required for a particular component.

```crystal
class MyFirstComponent < Motion::Base
  prop title : String

  def render
    html_doctype
    head do
      css_link "/css/main.css"
      utf8_charset
      meta content: "text/html;charset=utf-8", http_equiv: "Content-Type"
      title "My First Component"
    end

    body do
      h1 { @title }
    end
  end
end
```

In your controller:

```crystal
render(MyFirstComponent, title: "Hello World")
```

or rendering from a component:

```crystal
m(MyFirstComponent, title: "Hello World") # m is shorthand for mount. mount is also acceptable
```

#### Blocks & Procs

Blocks & Procs can be passed to child components. This will allow you to create more generic & reusable components.

```crystal
class MyFirstComponent < Motion::Base
  prop title : Proc(void)

  def render
    html_doctype
    head do
      css_link "/css/main.css"
      utf8_charset
      meta content: "text/html;charset=utf-8", http_equiv: "Content-Type"
      title "My First Component"
    end

    body do
      title.call
    end
  end
end
```

In your parent component:

```crystal
title = Proc(void).new { h1 "Hello World!" }
m(MyFirstComponent, title: title)
```

## Motion Guide

Motion.cr allows you to mount special DOM elements that can be updated real-time from frontend interactions, backend state changes, or a combination of both. Some features include:

- **Websockets Communication** - Communication with your Amber backend is performed via websockets
- **No Full Page Reload** - The current page for a user is updated in place.
- **Fast DOM Diffing** - DOM diffing is performed when replacing existing content with new content.
- **Server Triggered Events** - Server-side events can trigger updates to arbitrarily many components via WebSocket channels.

Motion.cr is similar to [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view) (and even React!) in some key ways:

- **Partial Page Replacement** - Motion does not use full page replacement, but rather replaces only the component on the page with new HTML, DOM diffed for performance.
- **Encapsulated, consistent stateful components** - Components have continuous internal state that persists and updates. This means each time a component changes, new rendered HTML is generated and can replace what was there before.
- **Blazing Fast** - Communication does not have to go through the full Amber router and controller stack. No changes to your routing or controller are required to get the full functionality of Motion. Motions take less than 1ms to process with typical times being around 300μs.

### Installation

```sh
yarn add @andrewc910/motion.cr
```

In `main.js` add:

```js
import { createClient } from '@awcrotwell/motion';

const client = createClient();
```

### Building Motions

#### Frontend interactions

Frontend interactions can update your MotionComponents using standard JavaScript events that you're already familiar with: `change`, `blur`, form submission, and more. Motions default to click events however you can override this to make it any event you would like. You can invoke motions manually using JavaScript if you need to.

The primary way to handle user interactions on the frontend is by setting `motion_component` to `true` annotating `@[Motion::MapMethod]` any motion methods:

```crystal
# Whenever a user click with the portion of the
# page that contains this component,
# `add` will be invoked, the component will be rerendered
# and the dom will be updated with the new html
class MyMotionComponent < Motion::Base
  # Let motion know this is a motion component
  prop motion_component = true
  # Add your props that you plan to pass in or default
  prop total : Int32 = 0

  # Annotate any motion methods
  @[Motion::MapMethod]
  def add
    @total += 1
  end

  # render is what motion will invoke
  # to generate your components html
  def render
    # data_motion: add tells the motion JS library what method
    # to invoke when a user interacts with this component
    div do
      span do
        @total
        button data_motion: "add" do # data_motion: "add" defaults to a click event
                                     # data_motion: "mouseover->add" to make it a mouseover event
                                     # data_motion: "mouseover->add mouseout->add" to map multiple events to a single element
          "Increment" # button text
        end
      end
    end
  end
end

class MyFirstComponent < Motion::Base
  def render
    html_doctype
    head do
      css_link "/css/main.css"
      utf8_charset
      meta content: "text/html;charset=utf-8", http_equiv: "Content-Type"
      title "My First Component"
    end

    body do
      m(MyFirstMotionComponent)
    end
  end
end
```

This component can be rendered from your controller:

```crystal
render MyFirstComponent
```

Every time the "Increment" button is clicked, MyComponent will call the `add` method, re-render your component and send it back to the frontend to replace the existing DOM. All invocations of mapped motions will cause the component to re-render, and unchanged rendered HTML will not perform any changes.

#### Motion::Event and Motion::Element

Methods that are mapped using `@[Motion::MapMethod]` can choose to accept an `event` parameter which is a `Motion::Event`. This object has a `target` attribute which is a `Motion::Element`, the element in the DOM that triggered the motion. Useful state and attributes can be extracted from these objects, including value, selected, checked, form state, data attributes, and more.

```crystal
  @[Motion::MapMethod]
  def example(event)
    event.type # => "change"
    event.name # alias for type

    # Motion::Element instance, the element that received the event.
    event.target

    # Motion::Element instance, the element with the event handler and the `data-motion` attribute
    element = event.current_target
    # Alias for #current_target
    event.element


    # Element API examples
    element.tag_name # => "input"
    element.value # => "5"
    element.attributes # { class: "col-xs-12", ... }

    # DOM element with aria-label="..."
    element[:aria_label]

    # DOM element with data-extra-info="..."
    element.data[:extra_info]

    # ActionController::Parameters instance with all form params. Also
    # available on Motion::Event objects for convenience.
    element.form_data
  end
```

See the code for full API for [Event](https://andrewc910.github.io/motion.cr/Motion/Event.html) and [Element](https://andrewc910.github.io/motion.cr/Motion/Element.html).

## Limitations

- Due to the way that your components are replaced on the page, Components that set `motion_component` to `true` are limited to a single top-level DOM element. If you have multiple DOM elements in your template at the top level, you must wrap them in a single element. This is a similar limitation that React enforced until `React.Fragment` appeared and is for a very similar reason. Because of this, your upper most component (the component you call from the controller) cannot be a set `motion_component`. The top most component will return the entire html document to the controller and there is no way to wrap an entire document in a single tag.

- Motion generates the `initialize` method for you. You cannot define your own. To add an instance variable to the parameters & initialize it, add a prop like `prop name : String = "Default Name"`

## Roadmap

- Perodic Timers
- Stream Updates from Models
- Routing for a full SPA experience
- AJAX?(TBD)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/andrewc910/motion.cr/issues.

## License

The shard is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

<!---
### Backend interactions

Backend changes can be streamed to your Motion components in 2 steps.

1. Broadcast changes using ActionCable after an event you care about:

```ruby
class Todo < ApplicationModel
  after_commit :broadcast_created, on: :create

  def broadcast_created
    ActionCable.server.broadcast("todos:created", name)
  end
end
```

2. Configure your Motion component to listen to an ActionCable channel:

```ruby
class TopTodosComponent < Motion::Base
  stream_from "todos:created", :handle_created

  def initialize(count: 5)
    @count = count
    @todos = Todo.order(created_at: :desc).limit(count).pluck(:name)
  end

  def handle_created(name)
    @todos = [name, *@todos.first(@count - 1)]
  end
end
```

This will cause any user that has a page open with `MyComponent` mounted on it to re-render that component's portion of the page.

All invocations of `stream_from` connected methods will cause the component to re-render everywhere, and unchanged rendered HTML will not perform any changes.

## Periodic Timers

Motion can automatically invoke a method on your component at regular intervals:

```crystal
class ClockComponent < Motion::Base
  prop time : TimeSpan = Time.local

  every 1.second, :tick

  def tick
    @time = Time.now
  end
end
```
-->
