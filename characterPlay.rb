require 'gtk3'
require 'json'
require_relative 'roller'

class CharacterPlay
  def initialize(character) #intialise with character passed from loadcharacter
    @character = character
    @oddities = load_oddities
    @characters = read_characters
    create_character_window
  end

  def load_oddities #load items
    json_path = 'oddities.json'
    unless File.exist?(json_path)
      puts "Error: The file #{json_path} does not exist."
      return []
    end

    begin
      data = JSON.parse(File.read(json_path)) #read file
      data.values.flatten  # This combines all categories into a single array
    rescue JSON::ParserError => e
      puts "Error parsing #{json_path}: #{e.message}"
      []
    end
  end

  def read_characters #read charactercol.
    json_path = 'charactercol.json'
    unless File.exist?(json_path) && !File.zero?(json_path) #read file if it exists
      puts "Error: The file #{json_path} is missing or empty."
      return []
    end

    begin
      JSON.parse(File.read(json_path))
    rescue JSON::ParserError => e
      puts "Error parsing #{json_path}: #{e.message}"
      []
    end
  end

  def create_character_window #create the window
    @window = Gtk::Window.new("Character Sheet: #{@character['name']}")
    @window.set_size_request(400, 800)
    @window.border_width = 10
    @window.window_position = :center
    @window.signal_connect('delete_event') { save_character_data; @window.destroy }

    vbox = Gtk::Box.new(:vertical, 8)
    setup_name_and_level(vbox) #control methods
    setup_hp_controls(vbox)
    setup_silver_controls(vbox)
    setup_stat_controls(vbox)
    setup_dice_roll_controls(vbox)
    setup_equipment_controls(vbox)
    setup_add_remove_controls(vbox)

    @window.add(vbox)
    @window.show_all
  end

  def setup_name_and_level(vbox) #name and level from charactercol
    name_label = Gtk::Label.new("Name: #{@character['name']}")
    level_label = Gtk::Label.new("Level: #{@character['level']}")
    vbox.pack_start(name_label, expand: false, fill: false, padding: 0)
    vbox.pack_start(level_label, expand: false, fill: false, padding: 0)
  end

  def setup_hp_controls(vbox) #hp from charactercol
    hp_box = Gtk::Box.new(:horizontal, 6)
    hp_label = Gtk::Label.new("HP: #{@character['current_HP']}/#{@character['max_HP']}")
    setup_hp_adjustment_controls(hp_box, hp_label)
    vbox.pack_start(hp_box, expand: false, fill: false, padding: 0)
  end

  def setup_hp_adjustment_controls(box, label)
    down_button = Gtk::Button.new(label: "-") 
    up_button = Gtk::Button.new(label: "+")
    down_button.signal_connect("clicked") { update_hp(label, -1) } #adds and subtracts from current HP only
    up_button.signal_connect("clicked") { update_hp(label, 1) }
    box.pack_start(label, expand: true, fill: true, padding: 0)
    box.pack_start(down_button, expand: false, fill: false, padding: 0)
    box.pack_start(up_button, expand: false, fill: false, padding: 0)
  end

  def update_hp(label, change)
    current_hp = @character['current_HP'].to_i
    max_hp = @character['max_HP'].to_i
    new_hp = [[current_hp + change, 0].max, max_hp].min #ensure no less than 0 or more than max hp
    @character['current_HP'] = new_hp
    label.set_text("HP: #{new_hp}/#{max_hp}")
  end

  def setup_silver_controls(vbox)
    silver_box = Gtk::Box.new(:horizontal, 6)
    silver_label = Gtk::Label.new("Silver: #{@character['Silver']}") #pull silver from json file
    silver_entry = Gtk::Entry.new
    silver_entry.set_text(@character['Silver'].to_s)
    setup_silver_adjustment_controls(silver_box, silver_label, silver_entry)
    vbox.pack_start(silver_box, expand: false, fill: false, padding: 0)
  end

  def setup_silver_adjustment_controls(box, label, entry)
    down_button = Gtk::Button.new(label: "-")
    up_button = Gtk::Button.new(label: "+")
    down_button.signal_connect("clicked") { update_silver(label, entry, -1) } #buttons to adjust silver
    up_button.signal_connect("clicked") { update_silver(label, entry, 1) }
    box.pack_start(label, expand: true, fill: true, padding: 0)
    box.pack_start(entry, expand: true, fill: false, padding: 0)
    box.pack_start(down_button, expand: false, fill: false, padding: 0)
    box.pack_start(up_button, expand: false, fill: false, padding: 0)
  end

  def update_silver(label, entry, change) #method to update silver
    current_silver = @character['Silver'].to_i
    increment = entry.text.to_i * change #changes silver based on entry box value
    new_silver = [current_silver + increment, 0].max 
    @character['Silver'] = new_silver
    label.set_text("Silver: #{new_silver}")
  end

  def setup_stat_controls(vbox)
    @character['stats'].each do |stat, value|
      stat_box = Gtk::Box.new(:horizontal, 6)
      stat_label = Gtk::Label.new("#{stat}: #{value}")
      last_roll_entry = Gtk::Entry.new #roll entry simply to record last success and value, under stat is success
      last_roll_entry.editable = false
      roll_button = Gtk::Button.new(label: "Roll Stat")
      roll_button.signal_connect("clicked") { roll_stat_check(stat_label, value, last_roll_entry) }

      stat_box.pack_start(stat_label, expand: true, fill: true, padding: 0)
      stat_box.pack_start(last_roll_entry, expand: true, fill: false, padding: 0)
      stat_box.pack_start(roll_button, expand: false, fill: false, padding: 0)
      vbox.pack_start(stat_box, expand: false, fill: false, padding: 0)
    end
  end

  def roll_stat_check(label, stat_value, entry) #stat check method 1d20 roll under
    _, roll_result = Roller.roll('1d20') #call roller method
    success = roll_result <= stat_value.to_i
    entry.set_text("#{roll_result} #{(success ? 'Success' : 'Failure')}")
    entry.override_color(:normal, Gdk::RGBA.new(success ? 0 : 1, success ? 1 : 0, 0, 1))
  end

  def setup_equipment_controls(vbox)
    @equipment_box = Gtk::Box.new(:vertical, 6) #accessible for updating display in other methods
    update_equipment_display
    vbox.pack_start(@equipment_box, expand: false, fill: false, padding: 0)
  end

  def update_equipment_display
    @equipment_box.children.each { |child| @equipment_box.remove(child) }  # Remove all existing labels first
    @character['items'].each do |id| #pull items from character sheet based on json ID to be matched to oddities
      item = find_item_by_id(id)
      next if item.nil?

      item_label = Gtk::Label.new(format_item_description(item))
      item_label.set_justify(Gtk::Justification::LEFT)
      item_label.set_halign(Gtk::Align::START) 
      item_label.set_valign(Gtk::Align::START)

      item_label.margin_start = 20  
      item_label.margin_end = 20 

      @equipment_box.pack_start(item_label, expand: false, fill: false, padding: 0)
    end
    @equipment_box.show_all
  end

  def setup_add_remove_controls(vbox)
    add_button = Gtk::Button.new(label: "Add Item")
    remove_button = Gtk::Button.new(label: "Remove Item")

    add_button.signal_connect("clicked") { display_add_items_dialog }
    remove_button.signal_connect("clicked") { display_remove_items_dialog }

    button_box = Gtk::Box.new(:horizontal, 6)
    button_box.pack_start(add_button, expand: true, fill: true, padding: 0)
    button_box.pack_start(remove_button, expand: true, fill: true, padding: 0)

    vbox.pack_start(button_box, expand: false, fill: false, padding: 10)
  end


  def find_item_by_id(id) #match ID to oddities
    id = id.to_i
    @oddities.find { |item| item['ID'] == id }
  end

  def format_item_description(item) # format item for display based on categories in json oddities file
    description = "#{item['Name']} - #{item['Description']} (#{item['Effect']})"
    wrap_text(description, 50) #Only 50 characters per line.
  end

  def wrap_text(text, max_line_length) #ensure returned effects don't warp the window size
    words = text.split(' ')
    wrapped_text = ""
    line_length = 0 

    words.each do |word|
        if line_length + word.length > max_line_length
        wrapped_text += "\n"  # Insert a newline before length exceeded
        line_length = 0       # Reset the line length
        end
        wrapped_text += (line_length.zero? ? "" : " ") + word  # Don't add extra space at beginning of line'
        line_length += word.length + 1  # increment line length to keep track of where to break
    end

    wrapped_text
  end

  def display_add_items_dialog #called to modify items
    dialog = Gtk::Dialog.new(
      title: "Add Item",
      parent: @window,
      flags: :modal,
      buttons: [[Gtk::Stock::CLOSE, Gtk::ResponseType::CLOSE]]
    )
    dialog.set_size_request(600, 400)

    scrolled_window = Gtk::ScrolledWindow.new #create scrollable window
    scrolled_window.set_policy(:automatic, :automatic)
    vbox = Gtk::Box.new(:vertical, 5)

    @oddities.sort_by { |item| item['ID'] }.each do |item| #populate full item list from oddities
      button = Gtk::Button.new(label: item['Name'])
      button.signal_connect("clicked") do
        @character['items'] << item['ID'] # when an item name is clicked add the ID to charactercol and refresh
        update_equipment_display
        dialog.response(Gtk::ResponseType::CLOSE)
      end
      vbox.pack_start(button, expand: false, fill: false, padding: 0)
    end

    scrolled_window.add_with_viewport(vbox)
    dialog.child.pack_start(scrolled_window, expand: true, fill: true, padding: 0)
    dialog.show_all
    dialog.run
    dialog.destroy
  end


  def display_remove_items_dialog # called to remove items
    dialog = Gtk::Dialog.new(
      title: "Remove Item",
      parent: @window,
      flags: :modal,
      buttons: [[Gtk::Stock::CLOSE, Gtk::ResponseType::CLOSE]]
    )
    dialog.set_size_request(600, 400)

    scrolled_window = Gtk::ScrolledWindow.new #scrolled window
    scrolled_window.set_policy(:automatic, :automatic)
    vbox = Gtk::Box.new(:vertical, 5)

    current_items = @character['items'].map { |id| find_item_by_id(id) }.compact #populate window with item names of character sheet items only
    current_items.sort_by { |item| item['ID'] }.each do |item|
      button = Gtk::Button.new(label: item['Name'])
      button.signal_connect("clicked") do
        @character['items'].delete(item['ID']) #Remove the item by id from character col when clicked then refresh display
        update_equipment_display
        dialog.response(Gtk::ResponseType::CLOSE)
      end
      vbox.pack_start(button, expand: false, fill: false, padding: 0)
    end

    scrolled_window.add_with_viewport(vbox)
    dialog.child.pack_start(scrolled_window, expand: true, fill: true, padding: 0)
    dialog.show_all
    dialog.run
    dialog.destroy
  end

  def setup_dice_roll_controls(vbox) #for non-stat rolls
    last_roll_entry = Gtk::Entry.new
    last_roll_entry.editable = false  # Prevent editing, only display results
    last_roll_entry.width_chars = 4 

    align_last_roll = Gtk::Alignment.new(0.5, 0, 0, 0)
    align_last_roll.add(last_roll_entry)

    dice_box = Gtk::Box.new(:horizontal, 6) # Create box for the dice roll buttons
    ['4', '6', '8', '10', '12'].each do |sides| # Polyhedral sides array
        button = Gtk::Button.new(label: "d#{sides}")
        button.signal_connect("clicked") { roll_dice(sides, last_roll_entry) }
        dice_box.pack_start(button, expand: true, fill: true, padding: 0)
    end

    align_dice_box = Gtk::Alignment.new(0.5, 0, 0, 0)
    align_dice_box.add(dice_box)

    vbox.pack_start(align_last_roll, expand: false, fill: false, padding: 10)
    vbox.pack_start(align_dice_box, expand: false, fill: false, padding: 0)
  end

  def roll_dice(sides, entry) #helper method for dice roll buttons, non-stat
    _, total = Roller.roll("1d#{sides}")
    entry.text = total.to_s
  end

  def save_character_data
    @characters.map! do |char|
      char['name'] == @character['name'] ? @character : char
    end
    File.write('charactercol.json', JSON.pretty_generate(@characters)) # write the character as they currently stand back to charactercol, overwritin the previous character.
  rescue IOError => e
    puts "Error writing to charactercol.json: #{e.message}"
  end
end

