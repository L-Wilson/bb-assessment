import type { RecentUrl } from "../types";
import { CopyButton } from "./CopyButton";

interface Props {
  urls: RecentUrl[];
  onClear: () => void;
}

function truncate(str: string, max = 35) {
  return str.length > max ? str.slice(0, max) + "..." : str;
}

export function RecentUrls({ urls, onClear }: Props) {
  if (urls.length === 0) return null;

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <h2 className="text-sm font-semibold text-warm-700">Recent URLs</h2>
        <button
          onClick={onClear}
          className="text-xs text-warm-400 hover:text-warm-600"
        >
          Clear history
        </button>
      </div>

      <div className="divide-y divide-warm-100 rounded-lg border border-warm-200 bg-white">
        {urls.map((url) => (
          <div
            key={url.shortCode}
            className="flex items-center gap-2 px-4 py-2.5"
          >
            <div className="flex-1 min-w-0">
              <div className="truncate text-sm font-medium text-orange">
                {url.shortCode}
              </div>
              <div
                className="truncate text-xs text-warm-400"
                title={url.longUrl}
              >
                {truncate(url.longUrl)}
              </div>
            </div>
            <CopyButton text={url.shortUrl} />
          </div>
        ))}
      </div>
    </div>
  );
}
