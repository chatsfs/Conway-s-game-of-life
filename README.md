# Conway's Game of Life API

A Ruby on Rails API that simulates Conway's Game of Life with full REST endpoints and stability analysis.

## What is Conway's Game of Life?

Conway's Game of Life is a cellular automaton where cells on a grid evolve through generations based on simple rules:
- Live cells with 2-3 neighbors survive
- Dead cells with exactly 3 neighbors become alive
- All other cells die or stay dead

This creates fascinating emergent patterns like oscillators, spaceships, and stable structures.

## Features

- Create and manage multiple game instances
- Set initial cell patterns manually or randomly
- Advance through generations step by step
- Detect stability, oscillation, and extinction
- Export grids in multiple formats (JSON, RLE)
- Reset to initial states
- Population and boundary analysis

## API Endpoints

```
POST   /games              # Create new game
GET    /games/:id          # Get current game state
POST   /games/:id/advance  # Advance one generation
PUT    /games/:id/cells    # Set cells alive
POST   /games/:id/randomize # Random initialization
POST   /games/:id/reset    # Reset to initial state
GET    /games/:id/analysis # Stability & oscillation detection
GET    /games/:id/export   # Export grid data
DELETE /games/:id          # Delete game
```

## Requirements

- Ruby 3.3.0
- Rails 8.0+
- SQLite3 (development/test)
- Docker (for deployment)

## Development Setup

```bash
# Install dependencies
bundle install

# Setup database
rails db:create
rails db:migrate

# Run tests
bundle exec rspec

# Start development server
rails server
```

## Testing

Run the full test suite:
```bash
bundle exec rspec
```

For specific test files:
```bash
bundle exec rspec spec/models/game_spec.rb
bundle exec rspec spec/requests/games_spec.rb
```

## Code Quality

Check code style with RuboCop:
```bash
bundle exec rubocop
```

Security scan with Brakeman:
```bash
bundle exec brakeman
```

## Deployment with Kamal

This project is configured for deployment using Kamal.

### Prerequisites
- Docker installed locally
- Server with Docker installed
- Domain name pointing to your server

### Initial Setup

1. Configure your deployment settings:
```bash
# Copy and edit the deploy configuration
cp config/deploy.yml.example config/deploy.yml
```

2. Set up environment variables:
```bash
# Edit your deploy.yml with your server details
# Set your RAILS_MASTER_KEY in the secrets
```

3. First deployment:
```bash
# Setup the server
kamal setup

# Deploy the application
kamal deploy
```

### Regular Deployments

```bash
# Deploy latest changes
kamal deploy

# Check application status
kamal status

# View logs
kamal logs

# Rollback if needed
kamal rollback
```

## Example Usage

### Create a Game and Set Up Patterns

```bash
# Create a new 10x10 game
curl -X POST http://localhost:3000/games \
  -H "Content-Type: application/json" \
  -d '{"width": 10, "height": 10}'
```

Response:
```json
{
  "id": 1,
  "width": 10,
  "height": 10,
  "generation": 0,
  "population": 0
}
```

### Set Up a Glider Pattern (Spaceship)

```bash
curl -X PUT http://localhost:3000/games/1/cells \
  -H "Content-Type: application/json" \
  -d '{"cells": [
    {"row": 1, "col": 2},
    {"row": 2, "col": 3},
    {"row": 3, "col": 1},
    {"row": 3, "col": 2},
    {"row": 3, "col": 3}
  ]}'
```

### Set Up a Blinker Pattern (Oscillator)

```bash
curl -X PUT http://localhost:3000/games/2/cells \
  -H "Content-Type: application/json" \
  -d '{"cells": [
    {"row": 2, "col": 1},
    {"row": 2, "col": 2},
    {"row": 2, "col": 3}
  ]}'
```

### Random Initialization

```bash
# Fill 30% of cells randomly
curl -X POST http://localhost:3000/games/1/randomize \
  -H "Content-Type: application/json" \
  -d '{"density": 0.3}'
```

### Advance Generations

```bash
# Advance one generation
curl -X POST http://localhost:3000/games/1/advance
```

Response:
```json
{
  "id": 1,
  "width": 10,
  "height": 10,
  "generation": 1,
  "population": 5
}
```

### Analysis and Export

```bash
# Check pattern stability and oscillation
curl http://localhost:3000/games/1/analysis
```

Response:
```json
{
  "population": 5,
  "generation": 1,
  "stable": false,
  "extinct": false,
  "oscillating": false,
  "oscillation_period": null,
  "bounds": {
    "min_row": 1,
    "max_row": 3,
    "min_col": 1,
    "max_col": 3,
    "width": 3,
    "height": 3
  }
}
```

```bash
# Export grid data
curl http://localhost:3000/games/1/export
```

Response:
```json
{
  "grid": [
    [false, false, false],
    [false, true, false],
    [false, false, true]
  ],
  "rle": "2bo$2b2o$o2bo!",
  "alive_cells": [
    {"row": 1, "col": 1},
    {"row": 2, "col": 2}
  ]
}
```

### Reset and Clear

```bash
# Reset to initial state
curl -X POST http://localhost:3000/games/1/reset

# Get current state
curl http://localhost:3000/games/1
```

## License

This project is available as open source under the MIT License.
