export function LoadingSpinner() {
  return (
    <div className="flex items-center justify-center gap-2 py-2">
      <div className="h-5 w-5 animate-spin rounded-full border-2 border-orange border-t-transparent" />
      <span className="text-sm text-warm-600">Shortening...</span>
    </div>
  );
}
