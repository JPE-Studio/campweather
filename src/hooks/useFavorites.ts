"use client";

import { useState, useCallback } from "react";
import { FavoriteLocation } from "@/types/weather";

const STORAGE_KEY = "weather-favorites";

function loadFavorites(): FavoriteLocation[] {
  if (typeof window === "undefined") return [];
  const stored = localStorage.getItem(STORAGE_KEY);
  if (!stored) return [];
  try {
    return JSON.parse(stored);
  } catch {
    return [];
  }
}

function saveFavorites(items: FavoriteLocation[]) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(items));
}

export function useFavorites() {
  const [favorites, setFavorites] = useState<FavoriteLocation[]>(loadFavorites);

  const addFavorite = useCallback((location: FavoriteLocation) => {
    setFavorites((prev) => {
      if (prev.some((f) => f.id === location.id)) return prev;
      const next = [...prev, location];
      saveFavorites(next);
      return next;
    });
  }, []);

  const removeFavorite = useCallback((id: string) => {
    setFavorites((prev) => {
      const next = prev.filter((f) => f.id !== id);
      saveFavorites(next);
      return next;
    });
  }, []);

  return { favorites, addFavorite, removeFavorite };
}
