# Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# Copyright (c) 2017 Michael J Welch, Ph.D. mjwelchphd@gmail.com
# All files in this distribution are subject to the terms of the MIT license.
#
# This work was based on Fellinger's Gestalt and Blueform, but is essentially
# a completely new version which is not a drop-in replacement for either.
# There's probably less than a dozen lines of Fellinger's original code left here.
# Nevertheless, the basic concept is Fellinger's, and it's a good one.
#
# This gem builds HTML code on-the-fly. The advantages are: (1) HTML code is
# properly formed with respect to tags and nesting; and (2) the code is dynamic,
# i.e., values from an object containing data (if used) are automatically
# extracted and inserted into the resultant HTML code, and if there are errors,
# the error message is generated also.
# 
# The French word démêler means "to unravel," and that's sort of what this gem
# does. It unravels your inputs to form HTML code. The diacritical marks are
# not used in the name for compatibility.
#
# This class doesn't depend on any particular framework, but I use it with
# Ruby Sequel.

class Demeler
  attr_reader :out, :obj, :usr

  # These calls are effectively generated in the same way as 'text' input
  # tags. Method_missing just does a substitution to implement them.
  MethodsLikeInputText = [:button, :color, :date, :datetime_local, :email, \
    :hidden, :image, :month, :number, :password, :range, :reset, :search, \
    :submit, :tel, :text, :time, :url, :week]

  ##
  # The default way to start building your markup.
  # Takes a block and returns the markup.
  #
  # @param [object] obj a Sequel::Model object, or Hash object with an added 'errors' field.
  # @param [boolean] gen_html A flag to control final output: true=>formatted, false=>compressed.
  # @param [*] usr The usr variable from the caller, although it can be anything because Demeler doesn't use it.
  # @param [Proc] block
  #
  def self.build(obj=nil, gen_html=false, usr=nil, &block)
    demeler = self.new(obj, usr, &block)
    if gen_html then demeler.to_html else demeler.to_s end
  end

  ##
  # Demeler.new builds HTML from Ruby code.
  # You can either access #out, .to_s or .to_html to
  # return the actual markup.
  #
  # A note of warning: you'll get extra spaces in textareas if you use .to_html.
  #
  # @param [object] obj--a Sequel::Model object, or Hash object with an added 'errors' field.
  # @param [*] usr The usr variable from the caller; it can be anything because Demeler doesn't use it.
  # @param [Proc] block
  #
  # To use this without Sequel, you can use an object like this:
  # class Obj<Hash
  #   attr_accessor :errors
  #   def initialize
  #     @errors = {}
  #   end
  # end
  #
  def initialize(obj=nil, usr=nil, &block)
    raise ArgumentError.new("The object passed to Demeler must have an errors field containing a Hash") if obj && !defined?(obj.errors)
    @obj = obj
    @usr = usr
    clear
    instance_eval(&block) if block_given?
  end

  ##
  # Clear out the data in order to start over with the same Demeler obj
  #
  def clear
    @level = 0
    @out = []
    @labels = []
    self
  end

  ##
  # Catch tag calls that have not been pre-defined.
  #
  # @param [String] meth The method that was called.
  # @param [Hash] args Additional arguments passed to the called method.
  # @param [Proc] block.
  #
  def method_missing(meth, *args, &block)
    # This code allows for some input tags that work like <input type="text" ...> to
    # work--for example g.password works in place of g.input(:type=>:password, ...)
    if MethodsLikeInputText.index(meth) # TODO!
      args << {} if !args[-1].kind_of?(Hash)
      args.last[:type] = meth
      meth = :input
    end
    tag_generator(meth, args, &block)
  end

  ##
  # Workaround for Kernel#p to make <p /> tags possible.
  #
  # @param [Hash] args Extra arguments that should be processed before
  #  creating the paragraph tag.
  # @param [Proc] block
  #
  def p(*args, &block)
    tag_generator(:p, args, &block)
  end

  ##
  # The #alink method simplyfies the generation of <a>...</a> tags.
  #
  # @param [String] The link line to be displayed
  # @param [Array] args Extra arguments that should be processed before
  #  creating the 'a' tag.
  # @param [Proc] block
  #
  def alink(text, args={}, parms={})Hash
    raise ArgumentError.new("In Demeler#alink, expected String for argument 1, text") if !text.kind_of?(String)
    raise ArgumentError.new("In Demeler#alink, expected Hash for argument 2, opts") if !args.kind_of?(Hash)
    raise ArgumentError.new("In Demeler#alink, expected an href option in opts") if !args[:href]

    href = args.delete(:href).to_s
    opts = args.clone
    if !parms.empty?
      href << '?'
      parms.each do |k,v|
        href << k.to_s
        href << '='
        href << v.to_s
        href << '&'
      end
    else
      href << '&' # will be removed
    end
    opts[:href] = href[0..-2] # remove last '&'
    opts[:text] = text
    tag_generator(:a, opts)
  end

  ##
  # The checkbox shortcut
  #
  # @param [Symbol] name Base Name of the control (numbers 1..n will be added)
  # @param [Hash] opts Attributes for the control
  # @param [Hash] value=>nomenclature pairs
  #
  # @example
  #  g.checkbox(:vehicle, opts, :volvo=>"Volvo", :saab=>"Saab", :mercedes=>"Mercedes", :audi=>"Audi")
  # @object [Sequel::Model]
  #  
  #
  # @note: first argument becomes the :name plus a number starting at 1, i.e., "vehicle1", etc.
  #
  def checkbox(name, opts, values)
    raise ArgumentError.new("In Demeler#checkbox, expected Symbol for argument 1, name") if !name.kind_of?(Symbol)
    raise ArgumentError.new("In Demeler#checkbox, expected Hash for argument 2, opts") if !opts.kind_of?(Hash)
    raise ArgumentError.new("In Demeler#checkbox, expected Hash for argument 3, values") if !values.kind_of?(Hash)
    n = 0
    data = if @obj then @obj[name] else nil end
    case data.class.name
    when "String"
      data = data.split(",")
    when "Array"
      # it's alreay in the form we want
    when "Hash"
      data = data.values
    else
      data = nil
    end
    values.each do |value,nomenclature|
      sets = opts.clone
      sets[:name] = "#{name}[#{n+=1}]".to_sym
      sets[:type] = :checkbox
      sets[:value] = value
      sets[:text] = nomenclature
      sets[:checked] = 'true' if data && data.index(value.to_s)
      tag_generator(:input, sets)
    end
  end

  ##
  # The radio shortcut
  #
  # @param [Symbol] name Base Name of the control (numbers 1..n will be added)
  # @param [Hash] opts Attributes for the control
  # @param [Hash] value=>nomenclature pairs
  #
  # @example
  #  g.radio(:vehicle, {}, :volvo=>"Volvo", :saab=>"Saab", :mercedes=>"Mercedes", :audi=>"Audi")
  #
  # @note: first argument is the :name; without the name, the radio control won't work
  #
  def radio(name, opts, values)
    raise ArgumentError.new("In Demeler#radio, expected Symbol for argument 1, name") if !name.kind_of?(Symbol)
    raise ArgumentError.new("In Demeler#radio, expected Hash for argument 2, opts") if !opts.kind_of?(Hash)
    raise ArgumentError.new("In Demeler#radio, expected Hash for argument 3, values") if !values.kind_of?(Hash)
    data = if @obj then @obj[name] else nil end
    values.each do |value,nomenclature|
      sets = opts.clone
      sets[:name] = "#{name}".to_sym
      sets[:type] = :radio
      sets[:value] = value
      sets[:text] = nomenclature
      sets[:checked] = 'true' if data==value.to_s
      tag_generator(:input, sets)
    end
  end

  ##
  # The select (select_tag) shortcut
  #
  # @param [Symbol] name The name of the SELECT statement
  # @param [Hash] opts Options for the SELECT statement
  # @param [Hash] values A list of :name=>value pairs the control will have
  #
  # @example
  #  g.select(:vehicle, {}, :volvo=>"Volvo", :saab=>"Saab", :mercedes=>"Mercedes", :audi=>"Audi")
  #
  # @note: first argument is the :name=>"vehicle"
  # @note: the second argument is a Hash or nil
  #
  def select(name, args, values)
    raise ArgumentError.new("In Demeler#select, expected Symbol for argument 1, name") if !name.kind_of?(Symbol)
    raise ArgumentError.new("In Demeler#select, expected Hash for argument 2, args") if !args.kind_of?(Hash)
    raise ArgumentError.new("In Demeler#select, expected Hash for argument 3, values") if !values.kind_of?(Hash)
    opts = {:name=>name}.merge(args)
    data = if @obj then @obj[name] else nil end
    tag_generator(:select, opts) do
      values.each do |value,nomenclature|
        sets = {:value=>value}
        sets[:selected] = 'true' if data==value.to_s
        sets[:text] = nomenclature
        tag_generator(:option, [sets])
      end
    end
  end

  ##
  # The submit shortcut
  #
  # @param [String] text The text which the button will display
  # @param [Hash] opts Options for the SUBMIT statement
  #
  # @example
  #  g.submit("Accept Changes", {})
  #
  def submit(text, opts={})
    attr = {:type=>:submit}
    attr[:value] = text
    attr.merge!(opts)
    tag_generator(:input, attr)
  end

  ##
  # The tag_generator method
  #
  # @param [Symbol] meth The type of control to be generated
  # @param [Hash] args Options for the tag being generated
  # @param [Proc] block A block which will be called to get input or nest tags
  #
  # @note The :text option will insert text between the opening and closing tag;
  #   It's useful to create one-line tags with text inserted.
  #
  def tag_generator(meth, args=[], &block)
    # this check catches a loop before it bombs the Demeler class
    raise StandardError.new("looping on #{meth.inspect}, @out=#{@out.inspect}") if (@level += 1)>500

    # This part examines the variations in possible inputs,
    # and rearranges them to suit tag_generator
    case
    when args.kind_of?(Hash)
      # args is a hash (attributes only)
      attr = args
    when args.size==0
      # args is empty array
      attr = {}
    when args.size==1 && args[0].kind_of?(String)
      # args is array of 1 string
      attr = {:text=>args[0]}
    when args.size==1 && args[0].kind_of?(Symbol)
      # args is array of 1 symbol (used as 'name')
      attr = {:name=>args[0]}
    when args.size==1 && args[0].kind_of?(Hash)
      # args is array of 1 hash (same as args is a hash)
      attr = args[0]
    when args.size==2 && args[0].kind_of?(Symbol) && args[1].kind_of?(Hash)
      # args is an array of symbol ('name') and hash ('attributes')
      # both name and attributes, i.e., g.div(:list, :class=>'list-class')
      attr = {:name=>args[0]}.merge(args[1])
    when args.size==2 && args[0].kind_of?(Symbol) && args[1].kind_of?(String)
      # args is array of symbol ('name') and string ('text')
      # both name and text, i.e., g.label(:list, "List")
      case meth
      when :label
        attr = {:for=>args[0]}.merge({:text=>args[1]})
        @labels << args[0]
      else
        attr = {:name=>args[0]}.merge({:text=>args[1]})
      end
    else
      raise ArgumentError.new("Too many arguments in Demeler#tag_generator: meth=>#{meth.inspect}, args=>#{args.inspect}")
    end

    # This part extracts a value out of the form's object (if any)
    name = attr[:name]
    case
    when name.nil?
    when @obj.nil?
    when !attr[:value].nil?
    when @obj[name].nil?
    when @obj[name].kind_of?(String) && @obj[name].empty?
    when meth==:textarea
      attr[:text] = @obj[name] if !attr.has_key?(:text)
    else
      attr[:value] = @obj[name] if !attr.has_key?(:value)
    end

    # If a label was previously defined for this :input,
    # add an :id attribute automatically
    attr[:id] = name if meth==:input && !attr.has_key?(:id) && @labels.index(name)

    # This part extracts the text (if any)--the text
    # is used in place of a block for tags like 'label'
    text = attr.delete(:text)
    case
    when text.nil?
      text = []
    when text.kind_of?(String)
      text = [text]
    when text.kind_of?(Array)
    else
      raise ArgumentError.new("In Demeler#tag_generator, expected Array or String for text (value for textarea, or ")
    end

    # make sure there's at least one (empty) string for textarea because
    # a textarea tag with no "block" makes the browser act wierd, even if it's
    # self-closing, i.e., <textarea ... />
    text = [""] if meth==:textarea && text.empty? && !block_given?

    # In case there is an error message for this field,
    # prepare the message now to add following the field
    if @obj && (list = @obj.errors[name])
      raise ArgumentError.new("The error message, if any, must be an array of Strings") if !list.kind_of?(Array)
      error = if [:input, :select].index(meth) then list.first else nil end
      message = if error then "<warn> <-- #{error}</warn>" else nil end
    else
      message = ""
    end

    # This is where the actual HTML is generated--it's structured this
    # way to be sure that only WHOLE tags are placed into @out--it's
    # done this way to facilitate #to_html
    case
    when !text.empty?
      temp = text.join("\n")
      @out << "<#{meth}#{attr.map{|k,v| %[ #{k}="#{v}"]}.join}>#{temp}</#{meth}>#{message}"
    when block_given?
      @out << "<#{meth}#{attr.map{|k,v| %[ #{k}="#{v}"]}.join}>"
      temp = yield
      @out << temp if temp && temp.kind_of?(String)
      @out << "</#{meth}>#{message}"
    else
      @out << "<#{meth}#{attr.map{|k,v| %[ #{k}="#{v}"]}.join} />#{message}"
    end

    @level -= 1
    nil
  end

  ##
  # Convert the final output of Demeler to a string.
  # This method has the following alias: "to_str".
  #
  # @return [String]
  #
  def to_s
    @out.join
  end

  ##
  # Method for converting the results of Demeler to a
  # human readable string. This isn't recommended for
  # production because it requires much more time to
  # generate the HTML output than to_s.
  #
  # @return [String] The formatted form output
  #
  def to_html
    # output the segments, but adjust the indentation
    indent = 0
    html = "<!-- begin generated output -->\n"
    @out.each do |part|
      case
      when part =~ /^<\/.*>$/
        indent -= 1
        html << write_html(indent,part)
      when part =~ /^<.*<\/.*>$/
        html << write_html(indent,part)
      when part =~ /^<.*\/>$/
        html << write_html(indent,part)
      when part =~ /^<.*>$/
        html << write_html(indent,part)
        indent += 1
      else
        html << write_html(indent,part)
      end
    end
    # return the formatted string
    html << "<!-- end generated output -->\n"
    return html
  end # to_html

private

  ##
  # This method is part of #to_html.
  #
  def write_html(indent,part)
#    "<!-- #{indent} --> #{' '*(if indent<0 then 0 else indent end)}#{part}\n"
    "#{' '*(if indent<0 then 0 else indent end)}#{part}\n"
  end

end
