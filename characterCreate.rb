require 'gtk3'
require 'json'
require_relative 'ui'
require_relative 'roller'
require_relative 'characterLoad'

class CharacterCreate
  def initialize(stack)
    @stack = stack #takes the stack from ui
    @vbox = Gtk::Box.new(:vertical, 6)
  end

  def setup_layout
    setup_user_interface
    add_back_to_welcome_button(@vbox, @stack)
    @vbox
  end


  def setup_user_interface
    @vbox = Gtk::Box.new(:vertical, 6) unless @vbox  # Only initialise if not already initialised

    name_entry = setup_entry("Enter character name") #entry box for name, silver, stats and hp
    hp_entry = setup_stat_entry("HP", "1d6")
    silver_entry = setup_stat_entry("Silver", "4d6")

    stats_entries = {}
    ['Strength', 'Dexterity', 'Willpower'].each do |stat| #done as array to conform with charactercol
        stats_entries[stat] = setup_stat_entry(stat, "3d6")
    end

    @oddities_text_view = setup_oddities_text_view
    setup_oddities_button
    setup_save_button(name_entry, hp_entry, silver_entry, stats_entries)
  end

  def add_back_to_welcome_button(vbox, stack) #back button to return to welcome using stack to navigate
    back_button = Gtk::Button.new(label: "Back")
    back_button.signal_connect("clicked") { stack.visible_child_name = "welcome" }
    vbox.pack_start(back_button, expand: false, fill: false, padding: 10)
  end

  def setup_entry(placeholder)  # general method for setting up the entry boxes
    entry = Gtk::Entry.new
    entry.placeholder_text = placeholder
    @vbox.pack_start(entry, expand: false, fill: false, padding: 0)
    entry
  end

  def setup_stat_entry(label_text, dice) # rolling for stats, to be passed 3d6
    hbox = Gtk::Box.new(:horizontal, 6)
    label = Gtk::Label.new(label_text)
    entry = Gtk::Entry.new
    button = Gtk::Button.new(label: "Roll #{label_text}")
    button.signal_connect("clicked") { entry.text = Roller.roll(dice).last.to_s } #roll method populates entry box with new stat
    hbox.pack_start(label, expand: false, fill: false, padding: 0)
    hbox.pack_start(entry, expand: true, fill: true, padding: 0)
    hbox.pack_start(button, expand: false, fill: false, padding: 0)
    @vbox.pack_start(hbox, expand: false, fill: false, padding: 0)
    entry
  end

  def setup_oddities_text_view # to generate rtandom equipment, features, etc
    scrolled_window = Gtk::ScrolledWindow.new
    scrolled_window.set_policy(Gtk::PolicyType::AUTOMATIC, Gtk::PolicyType::AUTOMATIC)
    text_view = Gtk::TextView.new
    text_view.editable = false
    text_view.cursor_visible = false
    scrolled_window.add(text_view)
    scrolled_window.set_size_request(380, 100)
    @vbox.pack_start(scrolled_window, expand: true, fill: true, padding: 0)
    text_view
  end

  def setup_oddities_button #when clicked will generate the random oddities.
    button = Gtk::Button.new(label: "Generate Oddities")
    button.signal_connect("clicked") do
      display_oddities
    end
    @vbox.pack_start(button, expand: false, fill: false, padding: 10)
  end

  def display_oddities #generates a list of 4 random IDs from oddities which are mapped to the character sheet when saved.
    ids = 4.times.map { rand(1..88) }
    oddities = read_oddities(ids) # calls read method to ensure name and effect are displayed
    update_text_view("Generated Oddities:\n" + oddities.join("\n"))
  end

  def update_text_view(text)
    buffer = @oddities_text_view.buffer
    buffer.set_text(text)
  end

  def read_oddities(ids) # ensures the readable view of the oddities is name and effect not ID.
    json_path = 'oddities.json'
    return [] unless File.exist?(json_path)

    begin
      json = File.read(json_path)
      data = JSON.parse(json)
      all_items = data.values.flatten  # Flatten all categories into a single array
      selected_items = all_items.select { |item| ids.include?(item['ID']) } # takes ID reference so output will be the name and effect.
      selected_items.map { |item| item['Name'] || item['Effect'] }
    rescue JSON::ParserError, Errno::ENOENT
      puts "Error reading the JSON file for oddities. Initializing with an empty array."
      []
    end
  end

  def setup_save_button(name_entry, hp_entry, silver_entry, stats_entries)
    save_button = Gtk::Button.new(label: "Save Character")
    save_button.signal_connect("clicked") do
      items = 4.times.map { rand(1..88) }
      save_character(name_entry.text, hp_entry.text.to_i, silver_entry.text.to_i, stats_entries, items)
    end
    @vbox.pack_start(save_button, expand: false, fill: false, padding: 10)
  end

  def save_character(name, hp, silver, stats_entries, items) # writes a new character to character col, takes the entry fields as its values.
    characters = read_characters
    new_character = {
      'name' => name,
      'level' => 'Novice',
      'Silver' => silver,
      'current_HP' => hp,
      'max_HP' => hp,
      'stats' => {
        'Strength' => stats_entries['Strength'].text.to_i,
        'Dexterity' => stats_entries['Dexterity'].text.to_i,
        'Willpower' => stats_entries['Willpower'].text.to_i
      },
      'items' => items
    }
    characters << new_character
    File.write('charactercol.json', JSON.pretty_generate(characters))
    puts "Character saved: #{new_character.inspect}"
  end

  def read_characters # reads the characters currently in charactercol, used to allow writing the new character as an append.
    json_path = 'charactercol.json'
    return [] unless File.exist?(json_path)

    begin
      json = File.read(json_path)
      JSON.parse(json)
    rescue JSON::ParserError, Errno::ENOENT
      puts "Error reading the JSON file. Initializing with an empty array."
      []
    end
  end
end

