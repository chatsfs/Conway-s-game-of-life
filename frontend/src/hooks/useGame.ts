import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { gameApi } from "@/lib/api-client";
import {
  CreateGameRequest,
  SetCellsRequest,
  RandomizeRequest,
  AdvanceStatesRequest,
  FinalStateRequest,
} from "@/types/game";

// Query keys
export const gameKeys = {
  all: ["games"] as const,
  detail: (id: number) => ["games", id] as const,
  nextState: (id: number) => ["games", id, "next"] as const,
  analysis: (id: number) => ["games", id, "analysis"] as const,
  export: (id: number) => ["games", id, "export"] as const,
};

// Get game state
export function useGame(id: number | null) {
  return useQuery({
    queryKey: gameKeys.detail(id!),
    queryFn: () => gameApi.getGame(id!),
    enabled: id !== null,
  });
}

// Get next state preview
export function useNextState(id: number | null) {
  return useQuery({
    queryKey: gameKeys.nextState(id!),
    queryFn: () => gameApi.getNextState(id!),
    enabled: id !== null,
  });
}

// Get analysis
export function useAnalysis(id: number | null, enabled = true) {
  return useQuery({
    queryKey: gameKeys.analysis(id!),
    queryFn: () => gameApi.getAnalysis(id!),
    enabled: id !== null && enabled,
    refetchInterval: 1000, // Refresh analysis every second during animation
  });
}

// Get export data
export function useExport(id: number | null) {
  return useQuery({
    queryKey: gameKeys.export(id!),
    queryFn: () => gameApi.exportGame(id!),
    enabled: false, // Manual trigger only
  });
}

// Create game mutation
export function useCreateGame() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (params: CreateGameRequest) => gameApi.createGame(params),
    onSuccess: (data) => {
      queryClient.setQueryData(gameKeys.detail(data.id), data);
    },
  });
}

// Advance game mutation
export function useAdvanceGame() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: number) => gameApi.advanceGame(id),
    onSuccess: (data) => {
      queryClient.setQueryData(gameKeys.detail(data.id), data);
      // Invalidate analysis to get fresh data
      queryClient.invalidateQueries({ queryKey: gameKeys.analysis(data.id) });
    },
  });
}

// Advance multiple states mutation
export function useAdvanceStates() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, params }: { id: number; params: AdvanceStatesRequest }) =>
      gameApi.advanceStates(id, params),
    onSuccess: (data) => {
      queryClient.setQueryData(gameKeys.detail(data.id), data);
      queryClient.invalidateQueries({ queryKey: gameKeys.analysis(data.id) });
    },
  });
}

// Get final state mutation
export function useFinalState() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, params }: { id: number; params: FinalStateRequest }) =>
      gameApi.getFinalState(id, params),
    onSuccess: (_, variables) => {
      // Refetch game state after reaching final state
      queryClient.invalidateQueries({ queryKey: gameKeys.detail(variables.id) });
      queryClient.invalidateQueries({ queryKey: gameKeys.analysis(variables.id) });
    },
  });
}

// Set cells mutation
export function useSetCells() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, params }: { id: number; params: SetCellsRequest }) =>
      gameApi.setCells(id, params),
    onSuccess: (data) => {
      queryClient.setQueryData(gameKeys.detail(data.id), data);
      queryClient.invalidateQueries({ queryKey: gameKeys.analysis(data.id) });
    },
  });
}

// Randomize mutation
export function useRandomize() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, params }: { id: number; params: RandomizeRequest }) =>
      gameApi.randomize(id, params),
    onSuccess: (data) => {
      queryClient.setQueryData(gameKeys.detail(data.id), data);
      queryClient.invalidateQueries({ queryKey: gameKeys.analysis(data.id) });
    },
  });
}

// Reset game mutation
export function useResetGame() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: number) => gameApi.resetGame(id),
    onSuccess: (data) => {
      queryClient.setQueryData(gameKeys.detail(data.id), data);
      queryClient.invalidateQueries({ queryKey: gameKeys.analysis(data.id) });
    },
  });
}

// Delete game mutation
export function useDeleteGame() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: number) => gameApi.deleteGame(id),
    onSuccess: (_, id) => {
      queryClient.removeQueries({ queryKey: gameKeys.detail(id) });
    },
  });
}
