"use client";

import { useState, useEffect, useRef } from "react";
import { GeocodingResult } from "@/types/weather";

interface AddFavoriteModalProps {
  onAdd: (result: GeocodingResult) => void;
  onClose: () => void;
  existingIds: string[];
}

export default function AddFavoriteModal({
  onAdd,
  onClose,
  existingIds,
}: AddFavoriteModalProps) {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<GeocodingResult[]>([]);
  const [loading, setLoading] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  useEffect(() => {
    if (query.length < 2) {
      return;
    }

    const timeout = setTimeout(async () => {
      setLoading(true);
      try {
        const res = await fetch(
          `/api/weather?q=${encodeURIComponent(query)}`,
          { method: "POST" }
        );
        const data = await res.json();
        if (Array.isArray(data)) {
          setResults(data);
        }
      } catch {
        // silently fail
      }
      setLoading(false);
    }, 300);

    return () => clearTimeout(timeout);
  }, [query]);

  const filteredResults = query.length < 2 ? [] : results;

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-[2000]">
      <div className="bg-white rounded-xl shadow-2xl w-full max-w-md mx-4 overflow-hidden">
        <div className="bg-gradient-to-r from-blue-600 to-blue-800 text-white px-4 py-3 flex items-center justify-between">
          <h2 className="font-bold">Ort hinzufügen</h2>
          <button
            onClick={onClose}
            className="text-white/80 hover:text-white text-xl leading-none"
          >
            ✕
          </button>
        </div>

        <div className="p-4">
          <input
            ref={inputRef}
            type="text"
            value={query}
            onChange={(e) => {
              setQuery(e.target.value);
              if (e.target.value.length < 2) {
                setResults([]);
              }
            }}
            placeholder="Stadt oder Ort suchen..."
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none text-sm"
          />

          {loading && (
            <div className="text-center py-4 text-gray-500 text-sm">
              Suche...
            </div>
          )}

          <div className="mt-2 max-h-64 overflow-y-auto">
            {filteredResults.map((result) => {
              const alreadyAdded = existingIds.includes(result.id);
              return (
                <button
                  key={result.id}
                  onClick={() => {
                    if (!alreadyAdded) {
                      onAdd(result);
                      onClose();
                    }
                  }}
                  disabled={alreadyAdded}
                  className={`w-full text-left px-4 py-3 rounded-lg mb-1 transition-colors ${
                    alreadyAdded
                      ? "bg-gray-100 text-gray-400 cursor-not-allowed"
                      : "hover:bg-blue-50 cursor-pointer"
                  }`}
                >
                  <div className="font-medium text-sm">{result.name}</div>
                  <div className="text-xs text-gray-500">
                    {[result.admin1, result.country].filter(Boolean).join(", ")}
                    {alreadyAdded && " — Bereits hinzugefügt"}
                  </div>
                </button>
              );
            })}

            {!loading && query.length >= 2 && results.length === 0 && (
              <div className="text-center py-4 text-gray-500 text-sm">
                Keine Ergebnisse gefunden
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
