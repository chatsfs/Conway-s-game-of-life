# Conway's Game of Life - Full Stack Application

A production-ready full-stack implementation of Conway's Game of Life with a Ruby on Rails API backend and a Next.js React frontend.

## 🎮 What is Conway's Game of Life?

Conway's Game of Life is a cellular automaton where cells on a grid evolve through generations based on simple rules:
- Live cells with 2-3 neighbors survive
- Dead cells with exactly 3 neighbors become alive
- All other cells die or stay dead

This creates fascinating emergent patterns like oscillators, spaceships, and stable structures.

## 🌟 Features

### Backend (Rails API)
- RESTful API for game state management
- Pattern stability and oscillation detection
- Automatic final state calculation
- Grid export in multiple formats (JSON, RLE)
- State persistence across server restarts
- Comprehensive test suite with RSpec
- Production-ready with Rails 8+ best practices

### Frontend (Next.js)
- Interactive canvas-based grid with drag-to-draw
- Real-time pattern analysis
- Built-in pattern library (Glider, Pulsar, R-pentomino, etc.)
- Adjustable simulation speed
- Play/pause controls with step-by-step advancement
- Random pattern generation
- Pattern export functionality
- Fully responsive design
- TypeScript for type safety
- React Query for efficient state management

## 📁 Project Structure

```
/
├── backend/          # Rails API
│   ├── app/
│   ├── spec/
│   ├── Dockerfile
│   └── README.md
├── frontend/         # Next.js App
│   ├── src/
│   ├── __tests__/
│   ├── Dockerfile
│   └── README.md
├── docker-compose.yml
├── docker-compose.dev.yml
└── README.md (this file)
```

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose (recommended)
- OR:
  - Ruby 3.3.0 (for backend)
  - Node.js 18+ (for frontend)

### Development with Docker Compose

```bash
# Start both backend and frontend in development mode
docker-compose -f docker-compose.dev.yml up

# Backend will be available at http://localhost:3000
# Frontend will be available at http://localhost:3001
```

### Manual Development Setup

#### Backend
```bash
cd backend
bundle install
rails db:create db:migrate
rails server  # Runs on port 3000
```

#### Frontend
```bash
cd frontend
npm install
npm run dev  # Runs on port 3001
```

## 🧪 Testing

### Backend Tests
```bash
cd backend
bundle exec rspec                 # Run all tests
bundle exec rubocop              # Lint code
bundle exec brakeman             # Security scan
```

### Frontend Tests
```bash
cd frontend
npm test                         # Unit tests
npm run test:e2e                # End-to-end tests
npm run lint                    # Lint code
npm run type-check              # TypeScript checks
```

## 🐳 Production Deployment

### Using Docker Compose
```bash
# Build and start production containers
docker-compose up -d

# Backend API: http://localhost:3000
# Frontend App: http://localhost:3001
```

### Individual Deployment

#### Backend (Kamal)
```bash
cd backend
# See backend/README.md for Kamal deployment instructions
kamal setup
kamal deploy
```

#### Frontend (Vercel/Netlify)
```bash
cd frontend
npm run build
# Deploy the .next folder to your platform
```

## 🛠️ Technology Stack

### Backend
- Ruby 3.3.0
- Rails 8.0+
- SQLite3 (development/test)
- RSpec, RuboCop, Brakeman
- Docker & Kamal

### Frontend
- Next.js 15+ (App Router)
- React 19
- TypeScript
- TailwindCSS
- React Query (TanStack Query)
- Zustand (UI state)
- Jest & React Testing Library
- Playwright (E2E)

## 📖 API Documentation

See [backend/README.md](backend/README.md) for complete API documentation.

### Quick Example
```bash
# Create a new game
curl -X POST http://localhost:3000/games \
  -H "Content-Type: application/json" \
  -d '{"width": 50, "height": 50}'

# Set cells (Glider pattern)
curl -X PUT http://localhost:3000/games/1/cells \
  -H "Content-Type: application/json" \
  -d '{"cells": [{"row": 1, "col": 2}, {"row": 2, "col": 3}, {"row": 3, "col": 1}, {"row": 3, "col": 2}, {"row": 3, "col": 3}]}'

# Advance one generation
curl -X POST http://localhost:3000/games/1/advance
```

## 🎨 Frontend Usage

See [frontend/README.md](frontend/README.md) for detailed frontend documentation.

### Key Features
- Click/drag on the grid to toggle cells
- Use the Pattern Library to load classic patterns
- Control simulation with Play/Pause and Step buttons
- Adjust speed with the slider
- View real-time analysis (stability, oscillation, bounds)
- Export patterns for sharing

## 🔄 CI/CD

GitHub Actions workflow runs on every push and PR:
- Backend: RSpec tests, RuboCop linting, Brakeman security scan
- Frontend: TypeScript checks, ESLint, tests, build verification
- Docker: Multi-stage build tests for both services

## 📝 License

This project is available as open source under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📚 Learn More

- [Conway's Game of Life - Wikipedia](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life)
- [Rails Guides](https://guides.rubyonrails.org/)
- [Next.js Documentation](https://nextjs.org/docs)
- [React Query Documentation](https://tanstack.com/query/latest)

## 🙏 Acknowledgments

- John Conway for creating the Game of Life
- The Rails and Next.js communities for excellent frameworks
- All contributors to the open-source libraries used in this project
