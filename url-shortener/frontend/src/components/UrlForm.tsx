import { useState } from "react";
import { ErrorMessage } from "./ErrorMessage";
import { LoadingSpinner } from "./LoadingSpinner";

interface Props {
  apiKey: string;
  onApiKeyChange: (key: string) => void;
  onSubmit: (url: string) => void;
  loading: boolean;
  error: string | null;
  onDismissError: () => void;
}

export function UrlForm({
  apiKey,
  onApiKeyChange,
  onSubmit,
  loading,
  error,
  onDismissError,
}: Props) {
  const [url, setUrl] = useState("");
  const [showApiKey, setShowApiKey] = useState(false);
  const [validationError, setValidationError] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setValidationError("");

    if (!apiKey.trim()) {
      setValidationError("API key is required");
      return;
    }

    try {
      new URL(url);
    } catch {
      setValidationError("Please enter a valid URL (e.g. https://example.com)");
      return;
    }

    onSubmit(url);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label
          htmlFor="api-key"
          className="mb-1.5 block text-sm font-medium text-warm-700"
        >
          API Key
        </label>
        <div className="relative">
          <input
            id="api-key"
            type={showApiKey ? "text" : "password"}
            value={apiKey}
            onChange={(e) => onApiKeyChange(e.target.value)}
            placeholder="Enter your API key"
            className="w-full rounded-lg border border-warm-300 bg-white px-4 py-2.5 pr-10 text-sm text-warm-900 placeholder:text-warm-400 focus:border-orange focus:ring-2 focus:ring-orange/20 focus:outline-none"
          />
          <button
            type="button"
            onClick={() => setShowApiKey(!showApiKey)}
            className="absolute top-1/2 right-3 -translate-y-1/2 text-warm-400 hover:text-warm-600"
          >
            {showApiKey ? (
              <svg
                width="18"
                height="18"
                viewBox="0 0 20 20"
                fill="currentColor"
              >
                <path
                  fillRule="evenodd"
                  d="M3.707 2.293a1 1 0 00-1.414 1.414l14 14a1 1 0 001.414-1.414l-1.473-1.473A10.014 10.014 0 0019.542 10C18.268 5.943 14.478 3 10 3a9.958 9.958 0 00-4.512 1.074l-1.78-1.781zm4.261 4.26l1.514 1.515a2.003 2.003 0 012.45 2.45l1.514 1.514a4 4 0 00-5.478-5.478z"
                  clipRule="evenodd"
                />
                <path d="M12.454 16.697L9.75 13.992a4 4 0 01-3.742-3.741L2.335 6.578A9.98 9.98 0 00.458 10c1.274 4.057 5.065 7 9.542 7 .847 0 1.669-.105 2.454-.303z" />
              </svg>
            ) : (
              <svg
                width="18"
                height="18"
                viewBox="0 0 20 20"
                fill="currentColor"
              >
                <path d="M10 12a2 2 0 100-4 2 2 0 000 4z" />
                <path
                  fillRule="evenodd"
                  d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z"
                  clipRule="evenodd"
                />
              </svg>
            )}
          </button>
        </div>
      </div>

      <div>
        <label
          htmlFor="long-url"
          className="mb-1.5 block text-sm font-medium text-warm-700"
        >
          URL to Shorten
        </label>
        <input
          id="long-url"
          type="text"
          value={url}
          onChange={(e) => {
            setUrl(e.target.value);
            setValidationError("");
          }}
          placeholder="https://example.com/very/long/path"
          className="w-full rounded-lg border border-warm-300 bg-white px-4 py-2.5 text-sm text-warm-900 placeholder:text-warm-400 focus:border-orange focus:ring-2 focus:ring-orange/20 focus:outline-none"
        />
      </div>

      {validationError && (
        <ErrorMessage
          message={validationError}
          onDismiss={() => setValidationError("")}
        />
      )}
      {error && <ErrorMessage message={error} onDismiss={onDismissError} />}

      {loading ? (
        <LoadingSpinner />
      ) : (
        <button
          type="submit"
          className="w-full rounded-lg bg-orange px-6 py-2.5 text-sm font-semibold text-white shadow-sm transition-colors hover:bg-orange-dark focus:ring-2 focus:ring-orange/40 focus:ring-offset-2 focus:outline-none"
        >
          Shorten URL
        </button>
      )}
    </form>
  );
}
