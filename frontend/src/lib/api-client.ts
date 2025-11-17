import axios, { AxiosInstance, AxiosError } from "axios";
import {
  Game,
  NextStateResponse,
  GameAnalysis,
  GameExport,
  FinalStateResponse,
  CreateGameRequest,
  SetCellsRequest,
  RandomizeRequest,
  AdvanceStatesRequest,
  FinalStateRequest,
  ApiError,
} from "@/types/game";

class GameApiClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000",
      timeout: Number(process.env.NEXT_PUBLIC_API_TIMEOUT) || 10000,
      headers: {
        "Content-Type": "application/json",
      },
    });

    // Add response interceptor for error handling
    this.client.interceptors.response.use(
      (response) => response,
      (error: AxiosError<ApiError>) => {
        if (error.response?.data) {
          throw new Error(error.response.data.error || "API request failed");
        }
        throw new Error(error.message || "Network error");
      }
    );
  }

  // Create a new game
  async createGame(params: CreateGameRequest): Promise<Game> {
    const response = await this.client.post<Game>("/games", params);
    return response.data;
  }

  // Get current game state
  async getGame(id: number): Promise<Game> {
    const response = await this.client.get<Game>(`/games/${id}`);
    return response.data;
  }

  // Get next state without advancing
  async getNextState(id: number): Promise<NextStateResponse> {
    const response = await this.client.post<NextStateResponse>(`/games/${id}/next`);
    return response.data;
  }

  // Advance one generation
  async advanceGame(id: number): Promise<Game> {
    const response = await this.client.post<Game>(`/games/${id}/advance`);
    return response.data;
  }

  // Advance multiple generations
  async advanceStates(id: number, params: AdvanceStatesRequest): Promise<Game> {
    const response = await this.client.post<Game>(`/games/${id}/advance_states`, params);
    return response.data;
  }

  // Get final stable/oscillating/extinct state
  async getFinalState(id: number, params: FinalStateRequest): Promise<FinalStateResponse> {
    const response = await this.client.post<FinalStateResponse>(
      `/games/${id}/final_state`,
      params
    );
    return response.data;
  }

  // Set cells alive
  async setCells(id: number, params: SetCellsRequest): Promise<Game> {
    const response = await this.client.put<Game>(`/games/${id}/cells`, params);
    return response.data;
  }

  // Randomize board
  async randomize(id: number, params: RandomizeRequest): Promise<Game> {
    const response = await this.client.post<Game>(`/games/${id}/randomize`, params);
    return response.data;
  }

  // Reset to initial state
  async resetGame(id: number): Promise<Game> {
    const response = await this.client.post<Game>(`/games/${id}/reset`);
    return response.data;
  }

  // Get analysis (stability, oscillation, etc.)
  async getAnalysis(id: number): Promise<GameAnalysis> {
    const response = await this.client.get<GameAnalysis>(`/games/${id}/analysis`);
    return response.data;
  }

  // Export grid data
  async exportGame(id: number): Promise<GameExport> {
    const response = await this.client.get<GameExport>(`/games/${id}/export`);
    return response.data;
  }

  // Delete game
  async deleteGame(id: number): Promise<void> {
    await this.client.delete(`/games/${id}`);
  }
}

// Export singleton instance
export const gameApi = new GameApiClient();
