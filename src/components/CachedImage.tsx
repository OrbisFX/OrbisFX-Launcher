import React, { useState, useEffect } from 'react';
import { invoke, convertFileSrc } from '@tauri-apps/api/core';

interface CachedImageProps extends React.ImgHTMLAttributes<HTMLImageElement> {
  src: string;
  fallbackSrc?: string;
}

interface CacheResult {
  success: boolean;
  cached_path?: string;
  from_cache?: boolean;
  stale?: boolean;
  error?: string;
  original_url?: string;
}

// In-memory cache to avoid redundant invoke calls during the same session
const memoryCache = new Map<string, string>();

/**
 * CachedImage component that automatically caches GitHub images locally
 * to prevent rate limiting issues.
 */
export const CachedImage: React.FC<CachedImageProps> = ({
  src,
  fallbackSrc,
  alt,
  className,
  ...props
}) => {
  const [imageSrc, setImageSrc] = useState<string>(src);
  const [isLoading, setIsLoading] = useState(true);
  const [hasError, setHasError] = useState(false);

  useEffect(() => {
    let isMounted = true;

    const loadImage = async () => {
      // Only cache GitHub raw content URLs
      if (!src.startsWith('https://raw.githubusercontent.com/')) {
        setImageSrc(src);
        setIsLoading(false);
        return;
      }

      // Check memory cache first
      const cached = memoryCache.get(src);
      if (cached) {
        setImageSrc(cached);
        setIsLoading(false);
        return;
      }

      try {
        const result = await invoke<CacheResult>('cache_github_image', { url: src });
        
        if (!isMounted) return;

        if (result.success && result.cached_path) {
          // Convert the local file path to a Tauri asset URL
          const assetUrl = convertFileSrc(result.cached_path);
          memoryCache.set(src, assetUrl);
          setImageSrc(assetUrl);
        } else {
          // Fallback to original URL if caching fails
          console.warn('Image caching failed:', result.error);
          setImageSrc(src);
        }
      } catch (error) {
        if (!isMounted) return;
        console.warn('Failed to cache image:', error);
        // Fallback to original URL
        setImageSrc(src);
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    };

    setIsLoading(true);
    setHasError(false);
    loadImage();

    return () => {
      isMounted = false;
    };
  }, [src]);

  const handleError = () => {
    setHasError(true);
    if (fallbackSrc && imageSrc !== fallbackSrc) {
      setImageSrc(fallbackSrc);
    }
  };

  if (hasError && !fallbackSrc) {
    return (
      <div className={`flex items-center justify-center bg-[#131b26] ${className || ''}`}>
        <span className="text-[#47516b] text-xs">Failed to load</span>
      </div>
    );
  }

  return (
    <img
      src={imageSrc}
      alt={alt}
      className={className}
      onError={handleError}
      onLoad={() => setIsLoading(false)}
      style={{ opacity: isLoading ? 0.5 : 1, transition: 'opacity 0.2s' }}
      {...props}
    />
  );
};

/**
 * Hook to get a cached image URL
 */
export const useCachedImage = (url: string): { src: string; isLoading: boolean } => {
  const [src, setSrc] = useState(url);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    let isMounted = true;

    const loadImage = async () => {
      if (!url.startsWith('https://raw.githubusercontent.com/')) {
        setSrc(url);
        setIsLoading(false);
        return;
      }

      const cached = memoryCache.get(url);
      if (cached) {
        setSrc(cached);
        setIsLoading(false);
        return;
      }

      try {
        const result = await invoke<CacheResult>('cache_github_image', { url });
        if (!isMounted) return;

        if (result.success && result.cached_path) {
          const assetUrl = convertFileSrc(result.cached_path);
          memoryCache.set(url, assetUrl);
          setSrc(assetUrl);
        } else {
          setSrc(url);
        }
      } catch {
        if (isMounted) setSrc(url);
      } finally {
        if (isMounted) setIsLoading(false);
      }
    };

    loadImage();
    return () => { isMounted = false; };
  }, [url]);

  return { src, isLoading };
};

