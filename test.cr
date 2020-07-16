annotation Methods
end

class Base
end

class MyFirstClass < Base
  @[Methods(name: "add")]
  def add
    puts "im adding"
  end
end

class MySecondClass < Base
  @[Methods(name: "sub")]
  def sub
    puts "im subtracting"
  end
end

class MyThirdClass < Base
  @[Methods(name: "mult")]
  def mult
    puts "im multiplying"
  end
end

class ActionClass
  macro generate_actions
    def invoke(component : Base, method_to_invoke : String)
      {% subclasses = Base.subclasses %}
      {% for klass in subclasses %}
        {% methods = klass.methods.map { |m| m.annotation(Methods)[:name] } %}
        if component.class == {{klass}}
          {% for method in methods %}
            if method_to_invoke == {{method}} && component.responds_to?({{method.id.symbolize}})
              component.{{method.id}}
            else
            end
          {% end %}
        else
        end
      {% end %}
      {{debug}}
    end
  end

  generate_actions
end

klass = MyFirstClass.new
method = "add"
ActionClass.new.invoke(klass, method)
