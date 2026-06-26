import React, { useState, useRef, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { RotateCw, ZoomIn, ZoomOut, X, Check } from 'lucide-react';
import { usePortalI18n } from '../lib/portal-i18n';

interface ImageCropperModalProps {
  src: string;
  isOpen: boolean;
  onClose: () => void;
  onApply: (croppedBlob: Blob) => void;
}

export const ImageCropperModal: React.FC<ImageCropperModalProps> = ({
  src,
  isOpen,
  onClose,
  onApply,
}) => {
  const { t } = usePortalI18n();
  const [zoom, setZoom] = useState(1);
  const [rotation, setRotation] = useState(0);
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const [baseScale, setBaseScale] = useState(1);
  const [isDragging, setIsDragging] = useState(false);

  const imgRef = useRef<HTMLImageElement>(null);
  const dragStart = useRef({ x: 0, y: 0 });
  const containerRef = useRef<HTMLDivElement>(null);

  const viewportSize = 256; // Target and UI viewport size in pixels

  // Reset states when modal is opened with new src
  useEffect(() => {
    if (isOpen) {
      setZoom(1);
      setRotation(0);
      setPosition({ x: 0, y: 0 });
      setBaseScale(1);
      setIsDragging(false);
    }
  }, [src, isOpen]);

  if (!isOpen) return null;

  const handleImageLoad = (e: React.SyntheticEvent<HTMLImageElement>) => {
    const img = e.currentTarget;
    const { naturalWidth, naturalHeight } = img;

    // Calculate base scale to completely cover the crop circle
    const scaleX = viewportSize / naturalWidth;
    const scaleY = viewportSize / naturalHeight;
    const initialBaseScale = Math.max(scaleX, scaleY);
    setBaseScale(initialBaseScale);
  };

  const handleStart = (clientX: number, clientY: number, e: React.SyntheticEvent) => {
    e.preventDefault();
    setIsDragging(true);
    dragStart.current = { x: clientX, y: clientY };
  };

  const handleMove = (clientX: number, clientY: number) => {
    if (!isDragging) return;
    const dx = clientX - dragStart.current.x;
    const dy = clientY - dragStart.current.y;

    // Adjust drag direction based on rotation
    let rx = dx;
    let ry = dy;
    if (rotation === 90) {
      rx = dy;
      ry = -dx;
    } else if (rotation === 180) {
      rx = -dx;
      ry = -dy;
    } else if (rotation === 270) {
      rx = -dy;
      ry = dx;
    }

    setPosition((prev) => ({
      x: prev.x + rx,
      y: prev.y + ry,
    }));
    dragStart.current = { x: clientX, y: clientY };
  };

  const handleEnd = () => {
    setIsDragging(false);
  };

  const handleRotate = () => {
    setRotation((prev) => (prev + 90) % 360);
  };

  const handleApply = () => {
    if (!imgRef.current) return;
    const img = imgRef.current;

    const canvas = document.createElement('canvas');
    canvas.width = viewportSize;
    canvas.height = viewportSize;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    // High quality scaling
    ctx.imageSmoothingEnabled = true;
    ctx.imageSmoothingQuality = 'high';

    // Clear canvas
    ctx.clearRect(0, 0, viewportSize, viewportSize);

    // 1. Translate to center of canvas
    ctx.translate(viewportSize / 2, viewportSize / 2);

    // 2. Apply drag translation
    ctx.translate(position.x, position.y);

    // 3. Rotate
    ctx.rotate((rotation * Math.PI) / 180);

    // 4. Scale (zoom factor * base scale)
    const finalScale = zoom * baseScale;
    ctx.scale(finalScale, finalScale);

    // 5. Draw image centered
    ctx.drawImage(img, -img.naturalWidth / 2, -img.naturalHeight / 2);

    canvas.toBlob(
      (blob) => {
        if (blob) {
          onApply(blob);
        }
      },
      'image/jpeg',
      0.95
    );
  };

  return createPortal(
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 dark:bg-black/80 backdrop-blur-sm animate-fade-in">
      <div
        ref={containerRef}
        className="portal-panel relative w-full max-w-[400px] rounded-[1.8rem] shadow-2xl overflow-hidden flex flex-col animate-scale-in"
      >
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-5 border-b border-border">
          <h3 className="portal-card-heading uppercase tracking-[0.12em]">
            {t('components.profilepanel.edit_photo')}
          </h3>
          <button
            onClick={onClose}
            className="p-1.5 rounded-lg text-muted-foreground hover:text-foreground hover:bg-accent transition-all cursor-pointer"
            aria-label="Close"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Viewport & Image Container */}
        <div className="relative h-[300px] w-full bg-black/40 flex items-center justify-center overflow-hidden">
          {/* Interactive touch area covering the whole cropping box */}
          <div
            className="relative w-[280px] h-[280px] flex items-center justify-center cursor-move overflow-hidden select-none touch-none"
            onMouseDown={(e) => handleStart(e.clientX, e.clientY, e)}
            onMouseMove={(e) => handleMove(e.clientX, e.clientY)}
            onMouseUp={handleEnd}
            onMouseLeave={handleEnd}
            onTouchStart={(e) => {
              if (e.touches[0]) {
                handleStart(e.touches[0].clientX, e.touches[0].clientY, e);
              }
            }}
            onTouchMove={(e) => {
              if (e.touches[0]) {
                handleMove(e.touches[0].clientX, e.touches[0].clientY);
              }
            }}
            onTouchEnd={handleEnd}
          >
            {/* The Image */}
            <img
              ref={imgRef}
              src={src}
              alt="Crop preview"
              onLoad={handleImageLoad}
              draggable={false}
              className="absolute pointer-events-none select-none max-w-none max-h-none origin-center"
              style={{
                left: '50%',
                top: '50%',
                transform: `translate(-50%, -50%) translate(${position.x}px, ${position.y}px) rotate(${rotation}deg) scale(${zoom * baseScale})`,
              }}
            />

            {/* Circular mask overlay to dim the area outside the circle */}
            <svg
              className="absolute inset-0 w-full h-full pointer-events-none text-black/70"
              viewBox="0 0 280 280"
              preserveAspectRatio="xMidYMid meet"
            >
              <defs>
                <mask id="crop-mask">
                  <rect width="280" height="280" fill="white" />
                  <circle cx="140" cy="140" r="128" fill="black" />
                </mask>
              </defs>
              <rect width="280" height="280" fill="currentColor" mask="url(#crop-mask)" />
              {/* Highlight Circle Border */}
              <circle cx="140" cy="140" r="128" fill="none" stroke="var(--color-primary, #10b981)" strokeWidth="2" strokeOpacity="0.6" />
            </svg>
          </div>
        </div>

        {/* Controls */}
        <div className="p-6 space-y-6 bg-accent/20 border-t border-border">
          {/* Zoom Slider */}
          <div className="space-y-2">
            <div className="portal-label flex items-center justify-between text-muted-foreground">
              <span>{t('components.profilepanel.zoom')}</span>
              <span className="portal-card-heading">{Math.round(zoom * 100)}%</span>
            </div>
            <div className="flex items-center gap-3">
              <ZoomOut className="w-4 h-4 text-muted-foreground shrink-0" />
              <input
                type="range"
                min="1"
                max="3"
                step="0.01"
                value={zoom}
                onChange={(e) => setZoom(parseFloat(e.target.value))}
                className="w-full h-1.5 bg-border rounded-lg appearance-none cursor-pointer accent-primary"
              />
              <ZoomIn className="w-4 h-4 text-muted-foreground shrink-0" />
            </div>
          </div>

          {/* Rotate Button */}
          <div className="flex justify-center">
            <button
              onClick={handleRotate}
              className="portal-action flex items-center gap-2 rounded-xl border border-border bg-background px-4 py-2 text-foreground hover:bg-accent transition-all cursor-pointer"
            >
              <RotateCw className="w-4 h-4" />
              {t('components.profilepanel.rotate')}
            </button>
          </div>
        </div>

        {/* Actions */}
        <div className="flex items-center gap-3 px-6 py-5 border-t border-border bg-accent/10">
          <button
            onClick={onClose}
            className="portal-action flex-1 rounded-xl bg-accent/30 py-3 text-muted-foreground transition-all cursor-pointer text-center hover:bg-accent/70 hover:text-foreground active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary"
          >
            {t('components.profilepanel.cancel')}
          </button>
          <button
            onClick={handleApply}
            className="portal-action flex-1 flex items-center justify-center gap-2 rounded-xl bg-primary py-3 text-primary-foreground transition-all cursor-pointer hover:bg-primary/90 hover:shadow-lg active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary"
          >
            <Check className="w-4 h-4" />
            {t('components.profilepanel.apply_crop')}
          </button>
        </div>
      </div>
    </div>,
    document.body
  );
};
