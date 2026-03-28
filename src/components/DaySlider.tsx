"use client";

import { useMemo } from "react";

interface DaySliderProps {
  selectedDay: number;
  onChange: (day: number) => void;
}

const DAY_NAMES = ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"];

export default function DaySlider({ selectedDay, onChange }: DaySliderProps) {
  const days = useMemo(() => {
    return Array.from({ length: 7 }, (_, i) => {
      const d = new Date();
      d.setDate(d.getDate() + i);
      const dayName = i === 0 ? "Heute" : DAY_NAMES[d.getDay()];
      const date = `${d.getDate()}.${d.getMonth() + 1}.`;
      return { index: i, dayName, date };
    });
  }, []);

  return (
    <div className="bg-white/95 backdrop-blur rounded-xl shadow-lg p-3">
      <div className="flex items-center gap-2">
        <button
          onClick={() => onChange(Math.max(0, selectedDay - 1))}
          disabled={selectedDay === 0}
          className="w-8 h-8 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200 disabled:opacity-30 disabled:cursor-not-allowed text-sm font-bold"
        >
          ‹
        </button>

        <div className="flex-1 flex gap-1">
          {days.map((day) => (
            <button
              key={day.index}
              onClick={() => onChange(day.index)}
              className={`flex-1 py-2 px-1 rounded-lg text-center transition-colors ${
                selectedDay === day.index
                  ? "bg-blue-600 text-white shadow-md"
                  : "hover:bg-gray-100 text-gray-700"
              }`}
            >
              <div className="text-xs font-medium">{day.dayName}</div>
              <div className="text-[10px] opacity-75">{day.date}</div>
            </button>
          ))}
        </div>

        <button
          onClick={() => onChange(Math.min(6, selectedDay + 1))}
          disabled={selectedDay === 6}
          className="w-8 h-8 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200 disabled:opacity-30 disabled:cursor-not-allowed text-sm font-bold"
        >
          ›
        </button>
      </div>

      <div className="mt-2">
        <input
          type="range"
          min={0}
          max={6}
          value={selectedDay}
          onChange={(e) => onChange(Number(e.target.value))}
          className="w-full h-1.5 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-blue-600"
        />
      </div>
    </div>
  );
}
