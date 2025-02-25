require 'gtk3'
require 'json'
require_relative 'ui'
require_relative 'characterPlay'

class CharacterLoad
  attr_reader :vbox #make the characterload vbox accessible

  def initialize(stack)
    @stack = stack #takes the stack from ui
    @vbox = Gtk::Box.new(:vertical, 6) 
  end

  def setup_layout
    add_back_to_welcome_button(@vbox, @stack)
    scrolled_window, vbox = setup_scrolling_view

    characters = read_characters
    display_character_count(vbox, characters)

    create_character_buttons(vbox, characters)
    @vbox.pack_start(scrolled_window, expand: true, fill: true, padding: 0)
    @vbox
  end

  def add_back_to_welcome_button(vbox, stack) #Uses the stack to return to welcome page
    back_button = Gtk::Button.new(label: "Back")
    back_button.signal_connect("clicked") { stack.visible_child_name = "welcome" }
    vbox.pack_start(back_button, expand: false, fill: false, padding: 10)
  end

  def setup_scrolling_view #scrolling view is used to accomodate many characters
    scrolled_window = Gtk::ScrolledWindow.new
    scrolled_window.set_policy(:automatic, :automatic)
    vbox = Gtk::Box.new(:vertical, 6)
    scrolled_window.add_with_viewport(vbox)
    [scrolled_window, vbox]
  end

  def display_character_count(vbox, characters) #counts total characters in json file
    count_label = Gtk::Label.new("Total Characters: #{characters.size}")
    vbox.pack_start(count_label, expand: false, fill: false, padding: 10)
  end

  def create_character_buttons(vbox, characters) #creates a horizontal box for each character and a dlete button to delete them
    characters.each do |char|
      hbox = Gtk::Box.new(:horizontal, 6)
      create_button(hbox, char, vbox)
      vbox.pack_start(hbox, expand: false, fill: false, padding: 0)
    end
  end

  def create_button(hbox, char, vbox)
    button = Gtk::Button.new(label: char["name"]) #delete button will remove the character from charactercol and refresh the list
    delete_button = Gtk::Button.new(label: "Delete")
    delete_button.signal_connect("clicked") do
      delete_character(char["name"])
      refresh_character_list(vbox)
    end
    button.signal_connect("clicked") { CharacterPlay.new(char) } #creates a character play window and passes it the clicked character.

    hbox.pack_start(button, expand: true, fill: true, padding: 0)
    hbox.pack_start(delete_button, expand: false, fill: false, padding: 0)
  end

  public def refresh_character_list(vbox) # made public to be accessed fom UI so that created characters appear
    puts "Activated refresh character list"
    vbox.children.each do |child| # Remove all children from vbox
        vbox.remove(child)
    end

    add_back_to_welcome_button(@vbox, @stack)
    scrolled_window, inner_vbox = setup_scrolling_view #re set up the view
    characters = read_characters
    display_character_count(inner_vbox, characters)
    create_character_buttons(inner_vbox, characters)
    vbox.pack_start(scrolled_window, expand: true, fill: true, padding: 0)
    vbox.show_all
  end


  def read_characters
    json_path = 'charactercol.json' #read the character sheets from JSON to save as characters array
    return [] unless File.exist?(json_path)

    json_data = File.read(json_path)
    begin
      characters = JSON.parse(json_data)
      raise TypeError, 'Data is not an array' unless characters.is_a?(Array)
      characters
    rescue JSON::ParserError, TypeError => e
      puts "Failed to parse JSON: #{e.message}"
      []
    end
  end

  def delete_character(name) #deltes a character from charactercol
    characters = read_characters
    updated_characters = characters.reject { |char| char["name"] == name }
    File.write('charactercol.json', JSON.pretty_generate(updated_characters))
  end
end
