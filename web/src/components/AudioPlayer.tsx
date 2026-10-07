"use client";

import { useRef, useState } from "react";

function formatTime(seconds: number): string {
  if (!Number.isFinite(seconds)) return "0:00";
  const m = Math.floor(seconds / 60);
  const s = Math.floor(seconds % 60);
  return `${m}:${String(s).padStart(2, "0")}`;
}

const SKIP_SECONDS = 5;
const VOLUME_DRAG_SENSITIVITY = 120; // px of horizontal drag for full 0-1 volume range

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
  const [volume, setVolume] = useState(1);
  const [muted, setMuted] = useState(false);

  const dragRef = useRef<{ startX: number; startVolume: number; moved: boolean } | null>(null);

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

  function applyVolume(value: number) {
    const audio = audioRef.current;
    if (!audio) return;
    const clamped = Math.min(Math.max(value, 0), 1);
    audio.volume = clamped;
    audio.muted = false;
    setVolume(clamped);
    setMuted(false);
  }

  function onVolumePointerDown(e: React.PointerEvent<HTMLButtonElement>) {
    dragRef.current = { startX: e.clientX, startVolume: volume, moved: false };
    e.currentTarget.setPointerCapture(e.pointerId);
  }

  function onVolumePointerMove(e: React.PointerEvent<HTMLButtonElement>) {
    const drag = dragRef.current;
    if (!drag) return;
    const deltaX = e.clientX - drag.startX;
    if (Math.abs(deltaX) > 3) drag.moved = true;
    if (drag.moved) {
      applyVolume(drag.startVolume + deltaX / VOLUME_DRAG_SENSITIVITY);
    }
  }

  function onVolumePointerUp(e: React.PointerEvent<HTMLButtonElement>) {
    const drag = dragRef.current;
    e.currentTarget.releasePointerCapture(e.pointerId);
    if (drag && !drag.moved) {
      // A plain click (no drag): toggle mute.
      const audio = audioRef.current;
      if (audio) {
        audio.muted = !audio.muted;
        setMuted(audio.muted);
      }
    }
    dragRef.current = null;
  }

  const showMuted = muted || volume === 0;

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
          className="flex h-8 w-8 shrink-0 items-center justify-center"
        >
          {isPlaying ? <PauseIcon /> : <PlayIcon />}
        </button>

        <span className="shrink-0 text-xs tabular-nums text-foreground-muted">
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

        <button
          onPointerDown={onVolumePointerDown}
          onPointerMove={onVolumePointerMove}
          onPointerUp={onVolumePointerUp}
          aria-label="Ovoz balandligi: ushlab chapga/o'ngga torting"
          title="Ovoz balandligi: ushlab chapga/o'ngga torting"
          className="flex h-9 w-9 shrink-0 cursor-ew-resize touch-none items-center justify-center"
        >
          {showMuted ? <MuteIcon /> : <VolumeIcon />}
        </button>
      </div>

      <div className="mt-3 flex items-center justify-center gap-5">
        {prevSlot}
        <button
          onClick={() => skip(-SKIP_SECONDS)}
          className="flex items-center gap-1 rounded-full bg-accent px-4 py-1.5 font-semibold text-black"
        >
          <span>‹</span>
          <span className="text-base">{SKIP_SECONDS}</span>
        </button>
        <button
          onClick={() => skip(SKIP_SECONDS)}
          className="flex items-center gap-1 rounded-full bg-accent px-4 py-1.5 font-semibold text-black"
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
    <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
      <path d="M8 5v14l11-7z" />
    </svg>
  );
}
function PauseIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
      <path d="M6 5h4v14H6zM14 5h4v14h-4z" />
    </svg>
  );
}
function VolumeIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor">
      <path d="M4 10v4h3.5l4 3.5v-11l-4 3.5zM16.5 12a3.5 3.5 0 0 0-2-3.17v6.34a3.5 3.5 0 0 0 2-3.17z" />
    </svg>
  );
}
function MuteIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor">
      <path d="M4 10v4h3.5l4 3.5v-11l-4 3.5zM19 9.5l-1.4-1.4-2.1 2.1-2.1-2.1L12 9.5l2.1 2.1-2.1 2.1 1.4 1.4 2.1-2.1 2.1 2.1 1.4-1.4-2.1-2.1z" />
    </svg>
  );
}
