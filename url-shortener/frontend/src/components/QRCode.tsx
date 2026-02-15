import { QRCodeSVG } from 'qrcode.react';

interface Props {
  url: string;
}

export function QRCode({ url }: Props) {
  return (
    <div className="inline-flex rounded-lg border border-warm-200 bg-white p-3">
      <QRCodeSVG value={url} size={100} bgColor="#ffffff" fgColor="#1a1a1a" />
    </div>
  );
}
