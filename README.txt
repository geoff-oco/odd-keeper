# Oddkeeper

Oddkeeper is a simple Ruby application designed to help you manage and track your characters for the TTRPG "Into the Odd." With a clean GTK3-based graphical interface, Oddkeeper lets you create new characters, roll dice for stats, and manage equipment and other oddities—all stored in JSON files.

## Features

- **Character Creation**
  - Enter character details such as name, HP, and silver.
  - Roll for stats (Strength, Dexterity, Willpower) using customizable dice expressions.
  - Generate random oddities (items/equipment) from a predefined JSON list.
  - Save characters to `charactercol.json`.

- **Character Management**
  - Load and view a list of saved characters.
  - Delete characters from the saved collection.
  - Update character attributes like HP, silver, and stats during gameplay.

- **Gameplay Interface**
  - Adjust character HP and silver in real-time.
  - Roll dice for stat checks and other actions.
  - Add or remove items from your character’s equipment, with details pulled from `oddities.json`.

## Requirements

- **Ruby** (version 2.5 or higher recommended)
- **GTK3 for Ruby** (install via the `gtk3` gem)
- **JSON** (comes standard with Ruby)

## Installation

1. **Install Ruby:** Make sure Ruby is installed on your system.
2. **Install GTK3:** Run the following command in your terminal:
3. **Clone or Download Oddkeeper:** Get all the project files, including the Ruby scripts and the JSON data files (`charactercol.json` and `oddities.json`).

## Running the Application

1. Open a terminal in the project directory.
2. Run the main script:
3. The Oddkeeper window will open, presenting you with options to create a new character or load an existing one.

## File Structure

- **main.rb** – The entry point of the application.
- **ui.rb** – Sets up the main interface and navigation using GTK's stack widget.
- **characterCreate.rb** – Handles character creation, including stat rolls and saving to JSON.
- **characterLoad.rb** – Manages loading, displaying, and deleting saved characters.
- **characterPlay.rb** – Provides the gameplay interface for editing and using a character.
- **roller.rb** – Contains dice rolling functionality used throughout the app.
- **charactercol.json** – JSON file used to store character data.
- **oddities.json** – JSON file containing various oddities (weapons, armour, equipment, etc.) available in the game.

## Contributing

If you'd like to contribute:
1. Fork the repository.
2. Create a new branch.
3. Make your changes and submit a pull request.

## Contact

For any questions or issues, reach out via GitHub: [geoff-oco](https://github.com/geoff-oco).

## Acknowledgements

Inspired by "Into the Odd" by Chris McDowall, Oddkeeper is your personal tool for managing all your TTRPG character needs.

Enjoy your adventure with Oddkeeper!
