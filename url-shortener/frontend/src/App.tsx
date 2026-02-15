import { UrlForm } from "./components/UrlForm";
import { UrlResult } from "./components/UrlResult";
import { RecentUrls } from "./components/RecentUrls";
import { useUrlShortener } from "./hooks/useUrlShortener";

export default function App() {
  const {
    result,
    loading,
    error,
    apiKey,
    setApiKey,
    recentUrls,
    shorten,
    refreshStats,
    reset,
    clearHistory,
  } = useUrlShortener();

  return (
    <div className="flex min-h-screen flex-col items-center bg-cream px-4 py-12">
      <div className="w-full max-w-lg">
        {/* Header */}
        <div className="mb-8 text-center">
          <h1 className="text-2xl font-bold text-warm-900">
            <span className="text-bb-orange">+</span>BB{" "}
            <span className="font-normal text-warm-500">URL Shortener</span>
          </h1>
          <p className="mt-1 text-sm text-warm-500">
            Shorten long URLs into shareable links
          </p>
        </div>

        {/* Main card */}
        <div className="rounded-xl border border-warm-200 bg-white p-6 shadow-sm">
          {result ? (
            <UrlResult
              result={result}
              onReset={reset}
              onRefresh={refreshStats}
            />
          ) : (
            <UrlForm
              apiKey={apiKey}
              onApiKeyChange={setApiKey}
              onSubmit={shorten}
              loading={loading}
              error={error}
              onDismissError={() => reset()}
            />
          )}
        </div>

        {/* Recent URLs */}
        {!result && recentUrls.length > 0 && (
          <div className="mt-6">
            <RecentUrls urls={recentUrls} onClear={clearHistory} />
          </div>
        )}

        {/* Footer */}
        <p className="mt-8 text-center text-xs text-warm-400">
          Platform Engineering Assessment &middot; Senior Cloud Infrastructure
          Engineer
        </p>
      </div>
    </div>
  );
}
