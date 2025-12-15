import React, { useState } from 'react';
import { Star } from 'lucide-react';

interface StarRatingProps {
  /** Current rating value (1-5) or null if not rated */
  rating: number | null;
  /** Average rating to display (optional, for showing community average) */
  averageRating?: number;
  /** Total number of ratings (optional) */
  totalRatings?: number;
  /** Whether the rating can be changed */
  interactive?: boolean;
  /** Callback when rating changes */
  onRate?: (rating: number) => void;
  /** Size of stars in pixels */
  size?: number;
  /** Whether to show the rating count */
  showCount?: boolean;
  /** Whether currently submitting a rating */
  isLoading?: boolean;
  /** Compact mode - smaller text */
  compact?: boolean;
}

export const StarRating: React.FC<StarRatingProps> = ({
  rating,
  averageRating,
  totalRatings = 0,
  interactive = false,
  onRate,
  size = 16,
  showCount = true,
  isLoading = false,
  compact = false,
}) => {
  const [hoverRating, setHoverRating] = useState<number | null>(null);
  
  // Use hover rating if hovering, otherwise use the actual rating
  const displayRating = hoverRating ?? rating ?? 0;
  
  // For display purposes, show average if provided, otherwise user rating
  const displayValue = averageRating ?? rating ?? 0;
  
  const handleClick = (starIndex: number) => {
    if (interactive && onRate && !isLoading) {
      onRate(starIndex);
    }
  };
  
  const handleMouseEnter = (starIndex: number) => {
    if (interactive && !isLoading) {
      setHoverRating(starIndex);
    }
  };
  
  const handleMouseLeave = () => {
    setHoverRating(null);
  };
  
  return (
    <div className="flex items-center gap-1.5">
      {/* Star display */}
      <div 
        className={`flex items-center gap-0.5 ${interactive ? 'cursor-pointer' : ''} ${isLoading ? 'opacity-50' : ''}`}
        onMouseLeave={handleMouseLeave}
      >
        {[1, 2, 3, 4, 5].map((starIndex) => {
          // Determine if this star should be filled
          // For interactive mode, use displayRating (which includes hover)
          // For non-interactive, use the displayValue (average or user rating)
          const fillValue = interactive ? displayRating : displayValue;
          const isFilled = starIndex <= Math.floor(fillValue);
          const isPartial = !isFilled && starIndex <= Math.ceil(fillValue) && fillValue % 1 > 0;
          const partialFill = isPartial ? (fillValue % 1) * 100 : 0;
          
          return (
            <div
              key={starIndex}
              className={`relative ${interactive ? 'transition-transform hover:scale-110' : ''}`}
              onClick={() => handleClick(starIndex)}
              onMouseEnter={() => handleMouseEnter(starIndex)}
            >
              {/* Background star (empty) */}
              <Star
                size={size}
                className="text-[var(--hytale-border-card)]"
                strokeWidth={1.5}
              />
              
              {/* Filled overlay */}
              {(isFilled || isPartial) && (
                <div
                  className="absolute inset-0 overflow-hidden"
                  style={{ width: isPartial ? `${partialFill}%` : '100%' }}
                >
                  <Star
                    size={size}
                    className={`${
                      interactive && hoverRating !== null
                        ? 'text-amber-400'
                        : rating !== null
                          ? 'text-amber-400'
                          : 'text-amber-500/70'
                    }`}
                    fill="currentColor"
                    strokeWidth={1.5}
                  />
                </div>
              )}
            </div>
          );
        })}
      </div>
      
      {/* Rating value and count */}
      {showCount && (
        <div className={`flex items-center gap-1 ${compact ? 'text-[10px]' : 'text-xs'} text-[var(--hytale-text-dim)]`}>
          {averageRating !== undefined && (
            <span className="font-medium text-[var(--hytale-text-secondary)]">
              {averageRating.toFixed(1)}
            </span>
          )}
          {totalRatings > 0 && (
            <span className="text-[var(--hytale-text-dimmer)]">
              ({totalRatings})
            </span>
          )}
          {totalRatings === 0 && !averageRating && (
            <span className="text-[var(--hytale-text-dimmer)] italic">
              No ratings
            </span>
          )}
        </div>
      )}
    </div>
  );
};

// Interactive rating component for user input
interface UserRatingProps {
  presetId: string;
  currentRating: number | null;
  onRate: (presetId: string, rating: number) => Promise<void>;
  size?: number;
}

export const UserRating: React.FC<UserRatingProps> = ({
  presetId,
  currentRating,
  onRate,
  size = 20,
}) => {
  const [isLoading, setIsLoading] = useState(false);
  const [localRating, setLocalRating] = useState<number | null>(currentRating);
  
  const handleRate = async (rating: number) => {
    setIsLoading(true);
    setLocalRating(rating);
    try {
      await onRate(presetId, rating);
    } catch (error) {
      // Revert on error
      setLocalRating(currentRating);
    }
    setIsLoading(false);
  };
  
  return (
    <div className="flex flex-col gap-1">
      <span className="text-xs text-[var(--hytale-text-dim)]">Your Rating</span>
      <StarRating
        rating={localRating}
        interactive={true}
        onRate={handleRate}
        size={size}
        showCount={false}
        isLoading={isLoading}
      />
    </div>
  );
};

export default StarRating;

