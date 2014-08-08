class Capybara::Artemis::Node < Capybara::Driver::Node
  def all_text
    Capybara::Helpers.normalize_whitespace(native.text)
  end

  def visible_text
    Capybara::Helpers.normalize_whitespace(unnormalized_text)
  end

  def [](name)
    string_node[name]
  end

  def value
    string_node.value
  end

  def tag_name
    native.node_name
  end

  def visible?
    string_node.visible?
  end

  def checked?
    string_node.checked?
  end

  def selected?
    string_node.selected?
  end

  def disabled?
    if %w(option optgroup).include? tag_name
      string_node.disabled? || find_xpath("parent::*")[0].disabled?
    else
      string_node.disabled?
    end
  end

  def path
    native.path
  end

  def find_xpath(locator)
    native.xpath(locator).map { |n| self.class.new(driver, n) }
  end

  def find_css(locator)
    native.css(locator).map { |n| self.class.new(driver, n) }
  end

  def ==(other)
    native == other.native
  end
  
  # Unsupported methods
  %w(set select_option unselect_option click right_click double_click hover drag_to).each do |method|
    define_method(method) do |*args|
      raise NotSupportedByDriverError, "Capybara::Artemis::Node##{method}"
    end
  end

protected

  def unnormalized_text()
    if !string_node.visible?
      ''
    elsif native.text?
      native.text
    elsif native.element?
      native.children.map do |child|
        Capybara::Artemis::Node.new(driver, child).unnormalized_text()
      end.join
    else
      ''
    end
  end

private

  def string_node
    @string_node ||= Capybara::Node::Simple.new(native)
  end
end
