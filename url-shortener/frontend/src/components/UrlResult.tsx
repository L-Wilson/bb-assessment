import type { ShortenResponse } from "../types";
import { CopyButton } from "./CopyButton";
import { QRCode } from "./QRCode";

interface Props {
  result: ShortenResponse;
  onReset: () => void;
  onRefresh: () => void;
}

function truncateUrl(url: string, maxLen = 50) {
  return url.length > maxLen ? url.slice(0, maxLen) + "..." : url;
}

function timeAgo(dateStr: string) {
  const seconds = Math.floor((Date.now() - new Date(dateStr).getTime()) / 1000);
  if (seconds < 60) return "just now";
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  return `${Math.floor(hours / 24)}d ago`;
}

export function UrlResult({ result, onReset, onRefresh }: Props) {
  return (
    <div className="space-y-5">
      {/* Success banner */}
      <div className="flex items-center gap-2 text-green-700">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
          <path
            fillRule="evenodd"
            d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
            clipRule="evenodd"
          />
        </svg>
        <span className="text-sm font-semibold">
          URL shortened successfully!
        </span>
      </div>

      {/* Short URL */}
      <div className="flex items-center gap-2 rounded-lg border border-warm-200 bg-warm-50 px-4 py-3">
        <a
          href={result.shortUrl}
          target="_blank"
          rel="noopener noreferrer"
          className="flex-1 truncate text-sm font-medium text-orange hover:underline"
        >
          {result.shortUrl}
        </a>
        <CopyButton text={result.shortUrl} />
      </div>

      {/* QR + Stats */}
      <div className="flex items-start gap-5">
        <QRCode url={result.shortUrl} />
        <div className="flex-1 space-y-2 pt-1 text-sm">
          <div>
            <span className="text-warm-500">Original:</span>{" "}
            <span className="text-warm-800" title={result.longUrl}>
              {truncateUrl(result.longUrl)}
            </span>
          </div>
          <div>
            <span className="text-warm-500">Clicks:</span>{" "}
            <span className="font-semibold text-warm-900">
              {result.clickCount}
            </span>
            <button
              onClick={onRefresh}
              className="ml-2 text-warm-400 hover:text-orange"
              title="Refresh stats"
            >
              <svg
                width="14"
                height="14"
                viewBox="0 0 20 20"
                fill="currentColor"
              >
                <path
                  fillRule="evenodd"
                  d="M4 2a1 1 0 011 1v2.101a7.002 7.002 0 0111.601 2.566 1 1 0 11-1.885.666A5.002 5.002 0 005.999 7H9a1 1 0 010 2H4a1 1 0 01-1-1V3a1 1 0 011-1zm.008 9.057a1 1 0 011.276.61A5.002 5.002 0 0014.001 13H11a1 1 0 110-2h5a1 1 0 011 1v5a1 1 0 11-2 0v-2.101a7.002 7.002 0 01-11.601-2.566 1 1 0 01.61-1.276z"
                  clipRule="evenodd"
                />
              </svg>
            </button>
          </div>
          <div>
            <span className="text-warm-500">Created:</span>{" "}
            <span className="text-warm-800">{timeAgo(result.createdAt)}</span>
          </div>
        </div>
      </div>

      <button
        onClick={onReset}
        className="w-full rounded-lg border border-warm-300 bg-white px-6 py-2.5 text-sm font-medium text-warm-700 transition-colors hover:bg-warm-50"
      >
        Shorten Another URL
      </button>
    </div>
  );
}
