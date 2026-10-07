export function Loading() {
  return (
    <div className="flex items-center justify-center py-10">
      <div className="h-6 w-6 animate-spin rounded-full border-2 border-accent-light border-t-transparent" />
    </div>
  );
}

export function ErrorBox({ message, onRetry }: { message: string; onRetry?: () => void }) {
  return (
    <div className="flex flex-col items-center gap-3 py-10 text-center">
      <p className="text-danger">{message}</p>
      {onRetry && (
        <button
          onClick={onRetry}
          className="rounded-full border border-accent-light px-4 py-1.5 text-sm text-accent-light"
        >
          Qayta urinish
        </button>
      )}
    </div>
  );
}
