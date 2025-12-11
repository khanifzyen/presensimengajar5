import { TouchableOpacity, Text, ActivityIndicator } from 'react-native';

interface ButtonProps {
    title: string;
    onPress: () => void;
    variant?: 'primary' | 'secondary' | 'outline' | 'danger';
    size?: 'sm' | 'md' | 'lg';
    disabled?: boolean;
    loading?: boolean;
    className?: string;
}

export function Button({
    title,
    onPress,
    variant = 'primary',
    size = 'md',
    disabled = false,
    loading = false,
    className = '',
}: ButtonProps) {
    const baseClasses = 'rounded-lg items-center justify-center font-medium';

    const variantClasses = {
        primary: 'bg-primary',
        secondary: 'bg-secondary',
        outline: 'border-2 border-primary bg-transparent',
        danger: 'bg-red-500',
    };

    const sizeClasses = {
        sm: 'px-3 py-2',
        md: 'px-4 py-3',
        lg: 'px-6 py-4',
    };

    const textClasses = {
        primary: 'text-white',
        secondary: 'text-white',
        outline: 'text-primary',
        danger: 'text-white',
    };

    const combinedClasses = `${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]} ${(disabled || loading) ? 'opacity-50' : ''} ${className}`;

    return (
        <TouchableOpacity
            onPress={onPress}
            disabled={disabled || loading}
            className={combinedClasses}
        >
            {loading && (
                <ActivityIndicator size="small" color="#ffffff" className="mr-2" />
            )}
            <Text className={`${textClasses[variant]} ${loading ? 'opacity-70' : ''}`}>
                {title}
            </Text>
        </TouchableOpacity>
    );
}