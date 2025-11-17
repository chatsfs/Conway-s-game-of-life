# Conway's Game of Life - Frontend

A production-ready Next.js frontend for Conway's Game of Life with interactive visualization and pattern analysis.

## Features

- **Interactive Canvas Grid**: Click and drag to toggle cells
- **Pattern Library**: Pre-loaded classic patterns (Glider, Pulsar, R-pentomino, etc.)
- **Real-time Analysis**: Automatic detection of stable, oscillating, and extinct states
- **Simulation Controls**: Play/pause, step-by-step, adjustable speed
- **Pattern Export**: Download game states as JSON
- **Responsive Design**: Works on desktop and mobile
- **Type-Safe**: Built with TypeScript for reliability
- **Optimized Performance**: Canvas rendering for smooth animations

## Tech Stack

- **Framework**: Next.js 15+ (App Router)
- **Language**: TypeScript
- **Styling**: TailwindCSS
- **State Management**: React Query + Zustand
- **HTTP Client**: Axios
- **Icons**: Lucide React
- **Testing**: Jest, React Testing Library, Playwright
- **Code Quality**: ESLint, Prettier

## Prerequisites

- Node.js 18+
- npm 9+
- Backend API running on port 3000 (or configure `NEXT_PUBLIC_API_URL`)

## Installation

```bash
# Install dependencies
npm install

# Copy environment variables
cp .env.example .env.local

# Edit .env.local if your API is not on localhost:3000
# NEXT_PUBLIC_API_URL=http://your-api-url
```

## Development

```bash
# Start development server
npm run dev

# Open http://localhost:3001
```

The app will automatically reload when you make changes.

## Building for Production

```bash
# Build the application
npm run build

# Start production server
npm start
```

## Testing

```bash
# Run unit tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage

# Run E2E tests
npm run test:e2e

# Run E2E tests with UI
npm run test:e2e:ui
```

## Code Quality

```bash
# Type checking
npm run type-check

# Linting
npm run lint

# Format code
npm run format

# Check formatting
npm run format:check
```

## Docker

### Development
```bash
# From project root
docker-compose -f docker-compose.dev.yml up frontend
```

### Production
```bash
# Build image
docker build -t conway-frontend .

# Run container
docker run -p 3001:3001 \
  -e NEXT_PUBLIC_API_URL=http://your-api \
  conway-frontend
```

## Project Structure

```
frontend/
├── src/
│   ├── app/              # Next.js app directory
│   │   ├── layout.tsx    # Root layout
│   │   ├── page.tsx      # Home page
│   │   ├── providers.tsx # React Query provider
│   │   └── globals.css   # Global styles
│   ├── components/       # React components
│   │   ├── GameContainer.tsx  # Main game orchestrator
│   │   ├── GameGrid.tsx       # Canvas grid renderer
│   │   ├── GameControls.tsx   # Play/pause/step controls
│   │   ├── GameInfo.tsx       # Stats and analysis display
│   │   └── PatternLibrary.tsx # Pattern selection modal
│   ├── hooks/            # React hooks
│   │   └── useGame.ts    # React Query hooks for API
│   ├── lib/              # Utilities
│   │   ├── api-client.ts # API client
│   │   ├── store.ts      # Zustand store
│   │   ├── utils.ts      # Helper functions
│   │   └── patterns.ts   # Pattern definitions
│   └── types/            # TypeScript types
│       └── game.ts       # Game-related types
├── public/               # Static assets
├── __tests__/            # Test files
├── e2e/                  # E2E tests
├── jest.config.js        # Jest configuration
├── playwright.config.ts  # Playwright configuration
├── next.config.ts        # Next.js configuration
├── tailwind.config.ts    # Tailwind configuration
├── tsconfig.json         # TypeScript configuration
└── package.json          # Dependencies and scripts
```

## Environment Variables

Create a `.env.local` file:

```bash
# Required: API backend URL
NEXT_PUBLIC_API_URL=http://localhost:3000

# Optional: API timeout in milliseconds
NEXT_PUBLIC_API_TIMEOUT=10000
```

## Key Components

### GameContainer
Main orchestrator that manages:
- Game initialization
- API interactions
- Animation loop
- Cell selection
- Pattern application

### GameGrid
Canvas-based grid renderer with:
- Click/drag cell toggling
- Visual feedback
- Optimized rendering

### GameControls
Control panel featuring:
- Play/Pause toggle
- Step forward
- Reset to initial state
- Randomize
- Find final state
- Speed adjustment

### GameInfo
Real-time stats display:
- Current generation
- Population count
- Stability detection
- Oscillation period
- Pattern bounds

### PatternLibrary
Modal with categorized patterns:
- Still Lifes (Block, Beehive, Loaf)
- Oscillators (Blinker, Toad, Pulsar)
- Spaceships (Glider, LWSS)
- Methuselahs (R-pentomino, Diehard, Acorn)

## API Integration

The frontend uses React Query for efficient API communication:

```typescript
// Example: Creating a game
const createGame = useCreateGame();
const game = await createGame.mutateAsync({
  width: 50,
  height: 50
});

// Example: Advancing the game
const advanceGame = useAdvanceGame();
await advanceGame.mutateAsync(gameId);

// Example: Getting analysis
const { data: analysis } = useAnalysis(gameId);
```

## State Management

### React Query (Server State)
- Game data from API
- Automatic caching and invalidation
- Optimistic updates
- Background refetching

### Zustand (UI State)
- Play/pause state
- Animation speed
- Selected cells
- Grid dimensions
- UI preferences

## Performance Optimizations

- Canvas rendering instead of DOM elements
- React Query caching to minimize API calls
- Memoized computations
- Optimized re-renders
- Standalone Next.js build for Docker

## Deployment

### Vercel (Recommended)
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Set environment variable
vercel env add NEXT_PUBLIC_API_URL
```

### Netlify
```bash
# Install Netlify CLI
npm i -g netlify-cli

# Build
npm run build

# Deploy
netlify deploy --prod
```

### Docker
See the Docker section above for containerized deployment.

## Troubleshooting

### API Connection Issues
- Ensure backend is running on the correct port
- Check `NEXT_PUBLIC_API_URL` in `.env.local`
- Verify CORS is configured on the backend

### Canvas Not Rendering
- Check browser console for errors
- Ensure grid dimensions are valid
- Try clearing browser cache

### Slow Performance
- Reduce grid size (default is 50x50)
- Lower animation speed
- Check for console warnings

## Browser Support

- Chrome/Edge: Latest 2 versions
- Firefox: Latest 2 versions
- Safari: Latest 2 versions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Run `npm run type-check && npm run lint && npm test`
6. Submit a pull request

## License

MIT License - see LICENSE file for details
