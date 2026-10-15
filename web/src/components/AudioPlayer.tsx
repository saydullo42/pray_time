"use client";

import { useRef, useState } from "react";

function formatTime(seconds: number): string {
  if (!Number.isFinite(seconds)) return "0:00";
  const m = Math.floor(seconds / 60);
  const s = Math.floor(seconds % 60);
  return `${m}:${String(s).padStart(2, "0")}`;
}

const SKIP_SECONDS = 5;

export function AudioPlayer({
  src,
  autoPlay,
  className = "",
  prevSlot,
  nextSlot,
}: {
  src: string;
  autoPlay?: boolean;
  className?: string;
  /** Rendered to the left of the "‹5" skip button, e.g. a previous-track link. */
  prevSlot?: React.ReactNode;
  /** Rendered to the right of the "5›" skip button, e.g. a next-track link. */
  nextSlot?: React.ReactNode;
}) {
  // Callers pass `key={src}` so this remounts (and state resets) on track change.
  const audioRef = useRef<HTMLAudioElement>(null);
  // Starts false regardless of `autoPlay`: browsers often block autoplay-with-sound,
  // and the onPlay/onPause events below are the source of truth for whether it's
  // actually playing, so the button never lies about state the browser rejected.
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);

  function togglePlay() {
    const audio = audioRef.current;
    if (!audio) return;
    if (audio.paused) {
      audio.play().catch(() => {});
    } else {
      audio.pause();
    }
  }

  function seek(value: number) {
    const audio = audioRef.current;
    if (!audio) return;
    const clamped = Math.min(Math.max(value, 0), duration || value);
    audio.currentTime = clamped;
    setCurrentTime(clamped);
  }

  function skip(delta: number) {
    seek(currentTime + delta);
  }

  return (
    <div className={className}>
      <div className="flex w-full items-center gap-3 rounded-full bg-surface px-4 py-2.5">
        <audio
          ref={audioRef}
          src={src}
          autoPlay={autoPlay}
          onPlay={() => setIsPlaying(true)}
          onPause={() => setIsPlaying(false)}
          onTimeUpdate={(e) => setCurrentTime(e.currentTarget.currentTime)}
          onLoadedMetadata={(e) => setDuration(e.currentTarget.duration)}
          onEnded={() => setIsPlaying(false)}
          className="hidden"
        />
        <button
          onClick={togglePlay}
          aria-label={isPlaying ? "Pauza" : "Ijro etish"}
          className="flex h-11 w-11 shrink-0 cursor-pointer items-center justify-center rounded-full bg-[#E5E4E2] text-black transition-colors hover:bg-[#d3d2d0] sm:h-9 sm:w-9"
        >
          {isPlaying ? <PauseIcon /> : <PlayIcon />}
        </button>

        <span className="shrink-0 text-sm tabular-nums text-foreground-muted sm:text-xs">
          {formatTime(currentTime)} / {formatTime(duration)}
        </span>

        <input
          type="range"
          min={0}
          max={duration || 0}
          step={0.1}
          value={currentTime}
          onChange={(e) => seek(Number(e.target.value))}
          className="h-1 flex-1 accent-foreground-muted"
        />
      </div>

      <div className="mt-3 flex items-center justify-center gap-5">
        {prevSlot}
        <button
          onClick={() => skip(-SKIP_SECONDS)}
          className="flex cursor-pointer items-center gap-1 rounded-full bg-[#E5E4E2] px-4 py-1.5 font-semibold text-black"
        >
          <span>‹</span>
          <span className="text-base">{SKIP_SECONDS}</span>
        </button>
        <button
          onClick={() => skip(SKIP_SECONDS)}
          className="flex cursor-pointer items-center gap-1 rounded-full bg-[#E5E4E2] px-4 py-1.5 font-semibold text-black"
        >
          <span className="text-base">{SKIP_SECONDS}</span>
          <span>›</span>
        </button>
        {nextSlot}
      </div>
    </div>
  );
}

function PlayIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="currentColor" className="h-6 w-6 sm:h-[18px] sm:w-[18px]">
      <path d="M8 5v14l11-7z" />
    </svg>
  );
}
function PauseIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="currentColor" className="h-6 w-6 sm:h-[18px] sm:w-[18px]">
      <path d="M6 5h4v14H6zM14 5h4v14h-4z" />
    </svg>
  );
}
