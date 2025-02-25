require 'gtk3'
require_relative 'characterCreate'
require_relative 'characterLoad'
require_relative 'characterPlay'

class UI
  def initialize #Initialise UI window and set aesthetics
    @window = Gtk::Window.new("Oddkeeper")
    @window.set_size_request(500, 400)
    @window.border_width = 10
    @window.window_position = :center
    @window.signal_connect('delete_event') { Gtk.main_quit }
    setup_ui
    @window.show_all
  end

  def setup_ui # set up the look of the UI.
    vbox = Gtk::Box.new(:vertical, 6)
    setup_stack(vbox)
    setup_buttons(vbox)
    @window.add(vbox)
  end

  def setup_stack(vbox) #set up the stack to be used for navigation
    @stack = Gtk::Stack.new
    @stack.transition_type = :slide_left_right
    @stack.transition_duration = 500

    welcome_page = setup_welcome_screen
    create_character_page = CharacterCreate.new(@stack).setup_layout
    @character_load_instance = CharacterLoad.new(@stack)  # Store the instance
    load_character_page = @character_load_instance.setup_layout  # Use setup_layout to get the UI elements

    @stack.add_titled(welcome_page, "welcome", "Welcome")
    @stack.add_titled(create_character_page, "create", "Create New Character")
    @stack.add_titled(load_character_page, "load", "Load Character")

    vbox.pack_start(@stack, expand: true, fill: true, padding: 0)
  end

  def setup_welcome_screen #set up the screen itself.
    vbox = Gtk::Box.new(:vertical, 10)
    label = Gtk::Label.new("Welcome to the Oddkeeper!!!!\nYour personal hireling for keeping track of all your Into the Odd needs.\nInto the Odd is an Epic TTRPG created by Chris McDowall.\nChoose an option to get started.")
    label.set_padding(10, 10) 
    label.margin_start = 20   
    label.margin_end = 20  
    label.margin_top = 10      
    label.margin_bottom = 10
    label.set_halign(Gtk::Align::CENTER) #align text and justification to centred
    label.set_justify(Gtk::Justification::CENTER)
    vbox.pack_start(label, expand: true, fill: true, padding: 10)
    vbox
  end

  def setup_buttons(vbox) #set up buttons for load and create characters
    create_button = Gtk::Button.new(label: "Create New Character")
    create_button.signal_connect("clicked") { @stack.visible_child_name = "create" }

    load_button = Gtk::Button.new(label: "Load Character")
    load_button.signal_connect("clicked") do
        @character_load_instance.refresh_character_list(@character_load_instance.vbox) if @character_load_instance #ensure character list is refreshed when a new character is created.
        @stack.visible_child_name = "load"
    end

    button_box = Gtk::Box.new(:horizontal, 6)
    button_box.pack_start(create_button, expand: true, fill: true, padding: 10)
    button_box.pack_start(load_button, expand: true, fill: true, padding: 10)

    vbox.pack_start(button_box, expand: false, fill: false, padding: 0)
  end


end

if __FILE__ == $0
  Gtk.init
  ui = UI.new
  Gtk.main
end