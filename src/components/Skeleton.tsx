import React from 'react';

interface SkeletonProps {
  className?: string;
  variant?: 'text' | 'circular' | 'rectangular' | 'rounded';
  width?: string | number;
  height?: string | number;
  animation?: 'pulse' | 'shimmer' | 'none';
}

export const Skeleton: React.FC<SkeletonProps> = ({
  className = '',
  variant = 'rectangular',
  width,
  height,
  animation = 'shimmer',
}) => {
  const baseClasses = 'bg-[var(--hytale-bg-elevated)]';
  
  const variantClasses = {
    text: 'rounded',
    circular: 'rounded-full',
    rectangular: '',
    rounded: 'rounded-lg',
  };

  const animationClasses = {
    pulse: 'animate-pulse',
    shimmer: 'skeleton-shimmer',
    none: '',
  };

  const style: React.CSSProperties = {
    width: width ?? '100%',
    height: height ?? (variant === 'text' ? '1em' : '100%'),
  };

  return (
    <div
      className={`${baseClasses} ${variantClasses[variant]} ${animationClasses[animation]} ${className}`}
      style={style}
      aria-hidden="true"
    />
  );
};

// Preset Card Skeleton
export const PresetCardSkeleton: React.FC = () => (
  <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg overflow-hidden">
    <Skeleton variant="rectangular" height={160} />
    <div className="p-4 space-y-3">
      <Skeleton variant="text" height={20} width="70%" />
      <Skeleton variant="text" height={14} width="50%" />
      <div className="flex gap-2">
        <Skeleton variant="rounded" height={24} width={60} />
        <Skeleton variant="rounded" height={24} width={80} />
      </div>
    </div>
  </div>
);

// Preset Row Skeleton
export const PresetRowSkeleton: React.FC = () => (
  <div className="flex items-center gap-4 p-4 bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg">
    <Skeleton variant="rounded" width={80} height={60} />
    <div className="flex-1 space-y-2">
      <Skeleton variant="text" height={18} width="40%" />
      <Skeleton variant="text" height={14} width="60%" />
    </div>
    <Skeleton variant="rounded" width={80} height={32} />
  </div>
);

// Screenshot Grid Skeleton
export const ScreenshotGridSkeleton: React.FC<{ count?: number }> = ({ count = 6 }) => (
  <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
    {Array.from({ length: count }).map((_, i) => (
      <div key={i} className="aspect-video">
        <Skeleton variant="rounded" height="100%" />
      </div>
    ))}
  </div>
);

// Stats Card Skeleton
export const StatsCardSkeleton: React.FC = () => (
  <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-4">
    <div className="flex items-center gap-3">
      <Skeleton variant="circular" width={40} height={40} />
      <div className="flex-1 space-y-2">
        <Skeleton variant="text" height={14} width="60%" />
        <Skeleton variant="text" height={24} width="40%" />
      </div>
    </div>
  </div>
);

// List Skeleton
export const ListSkeleton: React.FC<{ rows?: number; rowHeight?: number }> = ({ 
  rows = 5, 
  rowHeight = 60 
}) => (
  <div className="space-y-2">
    {Array.from({ length: rows }).map((_, i) => (
      <Skeleton key={i} variant="rounded" height={rowHeight} />
    ))}
  </div>
);

// Community Preset Card Skeleton
export const CommunityPresetCardSkeleton: React.FC = () => (
  <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg overflow-hidden">
    <Skeleton variant="rectangular" height={140} />
    <div className="p-4 space-y-3">
      <div className="flex items-center gap-2">
        <Skeleton variant="circular" width={24} height={24} />
        <Skeleton variant="text" height={14} width="40%" />
      </div>
      <Skeleton variant="text" height={18} width="80%" />
      <Skeleton variant="text" height={14} width="100%" />
      <div className="flex justify-between items-center pt-2">
        <Skeleton variant="rounded" height={20} width={60} />
        <Skeleton variant="rounded" height={28} width={80} />
      </div>
    </div>
  </div>
);

export default Skeleton;

